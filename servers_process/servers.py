from flask import Flask, request,jsonify
from process_images import process,extract_text
from translate import translator

"""
   if you want to use this app with your phone you need to change 2 line , first go to he summarizer_app/lib/main.dart and  go to the line 54-60 and 296-299 , it is very easy to do

   If you just want it to use it with your Computer you can just run server.py and main.dart
"""


app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload():
    global extracted_paragraph
    if 'image' not in request.files:
        return 'No image provided', 400 
    else:
        print("\nImage sended to  server , inside of upload function\n")
    
    file = request.files['image']
    model = request.form['model']


    # Process the image to extract text
    summary_text,extracted_paragraph= process(file,model)
    
    # Return the extracted text as JSON response
    return jsonify({'text': summary_text, 'paragraph': extracted_paragraph})


@app.route('/select_language', methods=['POST'])
def select_language():

    selected_language = request.form['language']
    

    print(f"selected language {selected_language}")
  
    translated_text = translator(extracted_paragraph,selected_language)   
    
    # Return a response
    return jsonify({'translated_text': translated_text})
    

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=50162,use_reloader=False)
