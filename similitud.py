import numpy as np
import csv

archivo_entrada = "matriz_distancias_autores.csv"
archivo_salida = "matriz_similitud_autores.csv"

matriz_resultante = []

with open(archivo_entrada, 'r') as file:
    lector = csv.reader(file)
    for fila in lector:
        nueva_fila = []
        for valor in fila:
            try:
                valor_num = float(valor)
                nueva_fila.append(np.exp(-valor_num))
            except ValueError:
                nueva_fila.append(valor)
        matriz_resultante.append(nueva_fila)

with open(archivo_salida, 'w', newline='') as file:
    escritor = csv.writer(file)
    escritor.writerows(matriz_resultante)
