import numpy as np
import csv

archivo_entrada = "matriz_similitud_autores.csv" 
archivo_salida = "matriz_transpuesta_autores.csv" 

with open(archivo_entrada, 'r') as file:
    lector = csv.reader(file)
    matriz_entrada = list(lector)

matriz_np = np.array(matriz_entrada)

matriz_transpuesta = matriz_np.T

with open(archivo_salida, 'w', newline='') as file:
    escritor = csv.writer(file)
    escritor.writerows(matriz_transpuesta)