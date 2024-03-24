from googletrans import Translator
import time

def translator(extracted_paragraph,selected_language) :
    
    print("inside translator")

    language_codes = {
        'English': 'en',
        'Turkish': 'tr',
        'French': 'fr',
        'German': 'de',
        'Spanish': 'es',
    }

    
    translator = Translator()
    dest_language_code = language_codes.get(selected_language)

    time.sleep(1)

    translated = translator.translate(extracted_paragraph, src='en', dest=dest_language_code)
    
    # Remove trailing whitespace and empty lines from translated text
    translated_text = "\n".join(line.strip() for line in translated.text.split("\n") if line.strip())

    return translated_text