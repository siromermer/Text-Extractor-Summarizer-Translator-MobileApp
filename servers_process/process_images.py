import cv2
import numpy as np 
import matplotlib.pyplot as plt
import pytesseract

from transformers import PegasusForConditionalGeneration, PegasusTokenizer
from transformers import BartForConditionalGeneration, BartTokenizer


# Mention the installed location of Tesseract-OCR in your system
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

# Initialize models and tokenizers outside the function scope
tokenizer_xsum = PegasusTokenizer.from_pretrained("google/pegasus-xsum")
model_xsum = PegasusForConditionalGeneration.from_pretrained("google/pegasus-xsum")

tokenizer_daily = PegasusTokenizer.from_pretrained("google/pegasus-cnn_dailymail")
model_daily = PegasusForConditionalGeneration.from_pretrained("google/pegasus-cnn_dailymail")

bart_model = BartForConditionalGeneration.from_pretrained('facebook/bart-large-cnn')
bart_tokenizer = BartTokenizer.from_pretrained('facebook/bart-large-cnn')

model_codes = {
        'xsum': [model_xsum,tokenizer_xsum],
        'pegasus-daily-maily': [model_daily,tokenizer_daily],
        'bart-daily-maily': [bart_model,bart_tokenizer],
        }


def process(file,model):
    
    combined_content = extract_text(file)

    summary = create_summary(combined_content,model)

    print("\nSummary is created")

    return summary


def create_summary(combined_content,model):
    
    print(" Creating summary , inside of  create_summary() function ")
    print(f"Selected model is : {model}\n")

    model_list = model_codes.get(model)
    model=model_list[0]
    tokenizer=model_list[1]
    
    tokens = tokenizer(combined_content, truncation=True, padding="longest", return_tensors="pt")
    summary = model.generate(**tokens, min_length=35)
    summary_text = tokenizer.decode(summary[0],skip_special_tokens=True)
    summary_text = summary_text.replace("<pad>", "").replace("</s>", "").replace("<n>", "")

    print(summary_text)

    return summary_text,combined_content


def extract_text(file):
    
    print("Text is extracting from sended image , inside of extract_text() function")

    # read image file string data
    filestr = file.read()
    # convert string data to numpy array
    file_bytes = np.fromstring(filestr, np.uint8)
    # convert numpy array to image
    image = cv2.imdecode(file_bytes, cv2.IMREAD_UNCHANGED)
    
    # if image.shape[0]>image.shape[1]:
    #     image = cv2.rotate(image, cv2.ROTATE_90_CLOCKWISE)

    print(image.shape)
    
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Performing OTSU threshold
    ret, thresh1 = cv2.threshold(gray, 0, 255, cv2.THRESH_OTSU | cv2.THRESH_BINARY_INV)

    # dilation parameter , bigger means less rect+
   
    rect_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (75, 75))

    # Applying dilation on the threshold image
    dilation = cv2.dilate(thresh1, rect_kernel, iterations=1)
    # Finding contours
    contours, hierarchy = cv2.findContours(dilation, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)

    # Creating a copy of image
    im2 = gray.copy()

    cnt_list = []
    for cnt in contours:
        x, y, w, h = cv2.boundingRect(cnt)

        # Drawing a rectangle on copied image
        rect = cv2.rectangle(im2, (x, y), (x + w, y + h), (0, 255, 0), 2)
        cv2.circle(im2, (x, y), 8, (255, 255, 0), 8)

        # Cropping the text block for giving input to OCR
        cropped = im2[y:y + h, x:x + w]
       
        # Apply OCR on the cropped image
        text = pytesseract.image_to_string(cropped)

        cnt_list.append([x, y, text])

    cv2.imwrite("image.jpeg",image)
    cv2.imwrite("paragraph_rectangles.jpeg",im2)
    cv2.imwrite("dilation.jpeg",dilation)
     
    # A text file is created
    file = open("extracted_text.txt", "w+")
    file.write("")
    file.close()

    # Sort the list with respect to their coordinates, in order from top to bottom
    sorted_list = sorted(cnt_list, key=lambda x: x[1])

    # Open the file in write mode to clear previous content
    with open("extracted_text.txt", "w") as file:
        # Write sorted text into the file
        for x, y, text in sorted_list:
            file.write(text.strip() + "\n")

    # Initialize an empty string to store the combined content
    combined_content = ""

    # Open the file in read mode
    with open("extracted_text.txt", "r") as file:
        # Read lines one by one and concatenate them
        for line in file:
            combined_content += line.strip() + " "

    print(combined_content)

    return combined_content

