import numpy as np
import pandas as pd

archivo_similitud = "matriz_similitud_autores.csv"
archivo_transpuesta = "matriz_transpuesta_autores.csv"
archivo_salida = "matriz_multiplicacion_autores.csv"

matriz_similitud = pd.read_csv(archivo_similitud, index_col=0)

matriz_transpuesta = pd.read_csv(archivo_transpuesta, index_col=0)

resultado_multiplicacion = np.dot(matriz_similitud, matriz_transpuesta)

resultado_df = pd.DataFrame(resultado_multiplicacion, index=matriz_similitud.index, columns=matriz_transpuesta.columns)

resultado_df.to_csv(archivo_salida)
