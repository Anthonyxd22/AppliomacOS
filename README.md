# Applio macOS 1.0.1. 🍏

Funciona con procesadores ARM Y  Con todas las Mac

1-Primer paso dercargar Python  3.10.0 https://www.python.org/downloads/release/python-3100/ ( Stable )

2- Segundo paso dercargar en dmg y asegurarte que la app este directorio Aplicaciones luego en la terminal le das permiso para poder usar la app sin restriciones sudo spctl --master-disable
codesign --deep --force --verify --verbose --sign "YourCertificateName" /Applications/Applio.app
codesign -dv --verbose=4 /Applications/Applio.app
spctl --assess --verbose /Applications/Applio.app
