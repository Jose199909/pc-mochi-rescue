# PC Mochi Rescue

Diagnóstico portátil de Windows para visitas técnicas. Ejecuta Mochi desde una memoria USB, revisa los hallazgos prioritarios y guarda un informe con lo que conviene comprobar.

**[Descargar PC Mochi Rescue v0.3 para Windows x64](https://github.com/Jose199909/pc-mochi-rescue/releases/download/v0.3/PC-Mochi-Rescue-v0.3-Windows-x64.zip)** · [Notas de la versión](https://github.com/Jose199909/pc-mochi-rescue/releases/tag/v0.3)

## Empezar

1. Descarga el ZIP portátil de 1,1 GB y extrae todo su contenido en una carpeta o memoria USB.
2. Abre `Abrir PC Mochi Rescue.cmd`. Elige **Revisión general**, **PC lento**, **Se reinicia** o **Sin Internet**.
3. Añade un número de caso si te sirve para identificar la visita y pulsa **Analizar PC**.
4. Revisa los hallazgos en **Resumen**. Abre **Informe completo** para ver las mediciones, copiar el texto o guardarlo.

## Qué revisa

- **Rendimiento y almacenamiento.** RAM disponible, espacio libre, programas de inicio y estado que Windows reporta para los discos.
- **Dispositivos y reinicios.** Códigos de error de dispositivos, eventos del sistema e indicadores de reinicio pendiente. Si indicas la hora aproximada de un reinicio, revisa los eventos de los 30 minutos anteriores y posteriores.
- **Conexión.** En el perfil **Sin Internet**, revisa la configuración básica de los adaptadores de red.

El resumen muestra hasta tres hallazgos. Cuando corresponde, cada uno abre una herramienta de Windows para comprobarlo. **Cancelar** detiene el análisis al terminar la comprobación en curso.

## Datos e IA local

El análisis es de solo lectura y funciona sin conexión. Los informes pueden incluir nombres de programas y dispositivos. Revísalos antes de compartirlos o adjuntarlos a un reporte de error.

El ZIP portátil incluye el motor y el modelo para Windows x64. Si solo descargas el código fuente, puedes utilizar el diagnóstico sin esos archivos. La pestaña **IA local** procesa las consultas en el equipo y ofrece sugerencias para que el técnico las valide.

- Modelo Qwen2.5-1.5B-Instruct Q4_K_M. [Archivos y licencia de Qwen](https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF)
- Motor llama.cpp b12129. [Versión del motor](https://github.com/ggml-org/llama.cpp/releases/tag/b12129)

Las licencias de los componentes incluidos están en la carpeta `IA` del ZIP.

## Reportar un problema

Si algo falla, indica la versión de Windows, el perfil de análisis y el mensaje que viste. Puedes abrir un [reporte en GitHub](https://github.com/Jose199909/pc-mochi-rescue/issues/new) con esos datos.
