# PC Mochi Rescue 0.3

Herramienta portátil para diagnosticar equipos Windows durante visitas técnicas. El análisis funciona sin Internet y es de solo lectura.

## Uso

1. Descarga `PC-Mochi-Rescue-v0.3-Windows-x64.zip` desde [Releases](https://github.com/Jose199909/pc-mochi-rescue/releases/tag/v0.3).
2. Extrae todo el ZIP en una carpeta o memoria USB.
3. Abre `Abrir PC Mochi Rescue.cmd`, elige el síntoma y pulsa **Analizar PC**.
4. Revisa el **Resumen** y guarda o copia el **Informe completo** si lo necesitas.

Puedes indicar la hora aproximada de un reinicio para consultar los eventos cercanos. El botón **Cancelar** detiene el análisis al terminar la comprobación en curso.

## IA local opcional

El ZIP portátil incluye el motor y el modelo para Windows x64. Si solo descargas el código fuente, puedes utilizar el diagnóstico sin esos archivos. La pestaña **IA local** procesa las consultas en el equipo y ofrece sugerencias para que el técnico las valide.

- Modelo Qwen2.5-1.5B-Instruct Q4_K_M. [Archivos y licencia de Qwen](https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF)
- Motor llama.cpp b12129. [Versión del motor](https://github.com/ggml-org/llama.cpp/releases/tag/b12129)

Las licencias de los componentes incluidos están en la carpeta `IA` del ZIP.
