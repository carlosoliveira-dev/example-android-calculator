# Calculadora Material

Calculadora para Android desenvolvida em Flutter com Material Design 3.

## Recursos

- Operacoes de adicao, subtracao, multiplicacao e divisao.
- Operacoes encadeadas, porcentagem e troca de sinal.
- Separador decimal com virgula, apagar digito e limpar.
- Tratamento de divisao por zero.

## Executar

Instale o Flutter SDK e configure um dispositivo Android ou emulador. Na raiz do projeto, execute:

```sh
flutter pub get
flutter run
```

Para gerar um APK de depuracao:

```sh
flutter build apk --debug
```

O APK sera criado em `build/app/outputs/flutter-apk/app-debug.apk`.

## Testes

```sh
flutter test
flutter analyze
```
