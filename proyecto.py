import pandas as pd
import re
import emoji
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
from nltk.stem import WordNetLemmatizer
import nltk

nltk.download('stopwords')
nltk.download('punkt')
nltk.download('wordnet')

data = pd.read_json("comentarios.json")

lematizar = WordNetLemmatizer()
stop_words = set(stopwords.words('english')).union(set(stopwords.words('spanish')))

def limpiar_texto(texto):
    texto = emoji.replace_emoji(texto, replace='')
    
    texto = re.sub(r"[^a-zA-Z0-9\s]", "", texto)
    
    palabras = word_tokenize(texto.lower())
 
    palabras = [palabra for palabra in palabras if palabra not in stop_words]
        
    palabras = [lematizar.lemmatize(palabra) for palabra in palabras]

    texto_limpio= " ".join(palabras) 
    return texto_limpio

data['comentario_limpio'] = data['comentario'].apply(limpiar_texto)

comentarios_limpios = data[['autor', 'comentario_limpio']].to_dict(orient='records')

import json
with open("comentarios_limpios.json", "w", encoding="utf-8") as f:    
    json.dump(comentarios_limpios, f, ensure_ascii=False, indent=4)