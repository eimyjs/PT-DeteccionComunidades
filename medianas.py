import numpy as np
import pandas as pd

archivo = "matriz_similitud_final.csv"
A_df = pd.read_csv(archivo, index_col=0)
A = A_df.values

medianas = []

for i in range(A.shape[0]):
    fila = A[i] 
    fila_sin_diagonal = np.delete(fila, i) 
    mediana = np.median(fila_sin_diagonal)  
    medianas.append(mediana)

medianas = np.array(medianas)

print("Vector de medianas:", medianas)

B = np.zeros_like(A)

for i in range(A.shape[1] - 1):
    for j in range(i + 1, A.shape[1]):
        if A[i, j] < medianas[i] and A[i, j] < medianas[j]:
            B[i, j] = np.exp(-A[i, j])
        else:
            B[i, j] = 0 

resultado_df = pd.DataFrame(B, index=A_df.index, columns=A_df.columns)
resultado_df.to_csv("matriz_final.csv")
