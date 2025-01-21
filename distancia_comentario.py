import pandas as pd
import numpy as np

data = pd.read_json("comentarios_limpios.json")

comentarios = data["comentario_limpio"]
autores = data["autor"]

n_comentarios = len(comentarios)
matriz_distancias = np.zeros((n_comentarios, n_comentarios))    

for i in range(n_comentarios - 1):
    for j in range(i + 1, n_comentarios):
        comentario_i = set(comentarios.iloc[i].split())
        comentario_j = set(comentarios.iloc[j].split())
        
        interseccion = len(comentario_i.intersection(comentario_j))
        union = len(comentario_i.union(comentario_j))
        
        jaccard = interseccion / union
        distancia = 1 - jaccard

        matriz_distancias[i, j] = distancia
        matriz_distancias[j, i] = distancia

df_matriz = pd.DataFrame(matriz_distancias, index=autores, columns=autores)
df_matriz.index.name = None
df_matriz.to_csv("matriz_distancias_comentarios.csv", index=True, header=True)
