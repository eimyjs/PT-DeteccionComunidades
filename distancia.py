import pandas as pd
import numpy as np

data = pd.read_json("comentarios_limpios.json")

autores = {}
indice_actual = 0
for autor in data["autor"]:
    if autor not in autores:
        autores[autor] = indice_actual
        indice_actual += 1

n = len(autores)
matriz_distancias = np.zeros((n, n), dtype=int)

for i in range(len(data)-1):
    for j in range(i+1, len(data)):
        autor_i = data.iloc[i]["autor"]
        autor_j = data.iloc[j]["autor"]
        indice_i = autores[autor_i]
        indice_j = autores[autor_j]
        if autor_i != autor_j:
            matriz_distancias[indice_i][indice_j] = 1
            matriz_distancias[indice_j][indice_i] = 1 

nombres_autores = [autor for autor, indice in sorted(autores.items(), key=lambda x: x[1])]

df_matriz = pd.DataFrame(matriz_distancias, index=nombres_autores, columns=nombres_autores)

df_matriz.to_csv("matriz_distancias_autores.csv", index=True, header=True)