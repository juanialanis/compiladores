#### Casos de prueba

- No acepta por mala declaración de variables

  ```
  int aux = 6;
  bool aux2 = 6;
  aux = aux + 1;
  RETURN aux;
  ```

- No acepta por nombre de variable repetidas

  ```
  int aux = 6;
  bool aux2 = FALSE;
  bool aux = FALSE;
  aux = aux + 1;
  RETURN aux;
  ```

- No acepta por uso de variables no declaradas

  ```
  int aux = 6;
  bool aux2 = FALSE;
  aux3 = aux + 1;
  RETURN aux;
  ```

  

  ```
  int aux = 6;
  bool aux2 = FALSE;
  aux = aux3 + 1;
  RETURN aux;
  ```

- No acepta por tipo incorrecto en la asignación

  ```
  int aux = 6;
  bool aux2 = FALSE;
  aux = FALSE;
  RETURN aux;
  ```

  ```
  int aux = 6;
  bool aux2 = FALSE;
  aux2 = 5;
  RETURN aux;
  ```

- No acepta por tipo incorrecto en las operaciones

  ```
  int aux = 6;
  bool aux2 = FALSE;
  aux2 = FALSE + 5;
  RETURN aux;
  ```

  ```
  int aux = 6;
  bool aux2 = FALSE;
  aux = FALSE + 5;
  RETURN aux;
  ```

- Acepta
  
  ```
  int aux = 6;
  bool aux2 = FALSE;
  aux = 6 + 5 + 7;
  RETURN aux;
  aux2 = TRUE * FALSE;
  RETURN aux2;
  ```
  ```
  bool aux = TRUE;
  bool isEmpty = FALSE;
  int x = 4;
  int x2 = aux * x + 158;
  RETURN x * FALSE;
  x = x + 5;
  RETURN (x * 100);
  ```