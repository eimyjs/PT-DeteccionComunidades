import pandas as pd
import numpy as np

archivo_similitud_autores = "matriz_similitud_autores_todos.csv"
archivo_similitud_comentarios = "matriz_similitud_comentarios_todos.csv"
archivo_transpuesta_comentarios = "matriz_transpuesta_comentarios_todos.csv"
archivo_multiplicacion_comentarios = "matriz_multiplicacion_comentarios_todos.csv"

def procesar_matriz(matriz, autores_unicos):
    matriz = matriz.groupby(matriz.index).sum()
    matriz = matriz.T.groupby(matriz.columns).sum().T
    matriz = matriz.loc[~matriz.index.duplicated(keep='first')]
    matriz = matriz.loc[:, ~matriz.columns.duplicated(keep='first')]
    matriz = matriz.reindex(index=autores_unicos, columns=autores_unicos, fill_value=0)
    return matriz

try:
    similitud_autores = pd.read_csv(archivo_similitud_autores, index_col=0)
    similitud_comentarios = pd.read_csv(archivo_similitud_comentarios, index_col=0)
    transpuesta_comentarios = pd.read_csv(archivo_transpuesta_comentarios, index_col=0)
    multiplicacion_comentarios = pd.read_csv(archivo_multiplicacion_comentarios, index_col=0)
   
    autores_unicos = similitud_autores.index

    similitud_comentarios = procesar_matriz(similitud_comentarios, autores_unicos)
    transpuesta_comentarios = procesar_matriz(transpuesta_comentarios, autores_unicos)
    multiplicacion_comentarios = procesar_matriz(multiplicacion_comentarios, autores_unicos)

    matriz_acoplada_vals = (
        similitud_comentarios.values +
        transpuesta_comentarios.values +
        multiplicacion_comentarios.values +
        similitud_autores.values
    )

    rango = matriz_acoplada_vals.max() - matriz_acoplada_vals.min()
    if rango == 0:
        raise ValueError("La matriz acoplada tiene un rango de valores igual a cero, no se puede normalizar.")

    matriz_normalizada_vals = (
        (matriz_acoplada_vals - matriz_acoplada_vals.min()) / rango
    )

    resultado_df = pd.DataFrame(
        matriz_normalizada_vals, index=autores_unicos, columns=autores_unicos
    )
    resultado_df.to_csv("matriz_similitud_final_todos.csv")

except Exception as e:
    print(f"Ocurrió un error al procesar las matrices: {e}")
