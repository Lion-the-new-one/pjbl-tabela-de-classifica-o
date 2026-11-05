# PjBL2: Tabela de Classificação de Campeonato — Haskell



Implementação funcional de um calculador de tabela de classificação e estatísticas de campeonato de futebol, estruturado em três camadas independentes utilizando exclusivamente a biblioteca padrão (`base`) do Haskell.



---



## 1. Ambiente de Execução



- **Ambiente principal:** GHC instalado localmente (via GHCup — compatível com GHC 9.x).

- **Dependências externas:** Nenhuma. Utiliza apenas módulos da biblioteca padrão (`Data.List`, `Data.Char`, `Data.Maybe`, `Data.Either`, `Data.Ord` e `Text.Read`).



---



## 2. Estrutura do Projeto



```text

projeto/

├── src/

│   ├── Tipos.hs           # Camada 1: Tipos algébricos (Resultado, Partida, Linha) e consultas básicas

│   ├── Classificacao.hs   # Camada 2: Cálculo de classificação e estatísticas com funções de ordem superior

│   ├── Leitura.hs         # Camada 3: Parsing e validação com Maybe, Either e formatação da tabela

│   ├── Dados.hs           # Campeonato de teste embutido como String (6 times, 5 rodadas) e entradas inválidas

│   └── Main.hs            # Demonstração sequencial das 3 camadas e tratamento de erros

├── tests/

│   └── Testes.hs          # Bateria de casos de teste automatizados cobrindo as 3 camadas e casos de borda

├── docs/

│   └── decisoes.md        # Justificativas das decisões de modelagem e limitações conhecidas

└── README.md              # Instruções de compilação e execução

```



---



## 3. Como Compilar e Executar (GHC Local)



Execute os comandos abaixo a partir da pasta raiz do projeto (`projeto/`).



### 3.1. Executar a Demonstração Completa (`Main.hs`)



- **Opção A — Compilando com verificação estrita (`-Wall`):**

  ```bash

  ghc -Wall -isrc src/Main.hs -o Main

  ./Main

  ```

  *(No Windows PowerShell/CMD, execute `.\Main.exe`)*



- **Opção B — Execução direta via `runghc` (sem gerar binário):**

  ```bash

  runghc -Wall -isrc src/Main.hs

  ```



### 3.2. Executar a Bateria de Testes (`Testes.hs`)



- **Opção A — Compilando o executável de testes:**

  ```bash

  ghc -Wall -isrc tests/Testes.hs -o Testes

  ./Testes

  ```

  *(No Windows PowerShell/CMD, execute `.\Testes.exe`)*



- **Opção B — Execução direta via `runghc`:**

  ```bash

  runghc -Wall -isrc tests/Testes.hs

  ```



---



## 4. Critérios de Desempate Adotados



Na função `classificacao` (Camada 2), as equipes são ordenadas de forma decrescente pelos seguintes critérios sucessivos:



1. Maior pontuação (`pontosLinha`: 3 por vitória, 1 por empate, 0 por derrota);

2. Maior número de vitórias (`vitorias`);

3. Maior saldo de gols (`saldo` = gols pró − gols contra);

4. Maior número de gols marcados (`golsPro`);

5. Ordem alfabética do nome do time (`time`).



---



## 5. Como Testar Tudo na Sua Máquina



Com todos os arquivos salvos nas respectivas pastas, rode estes dois comandos no terminal na raiz do repositório para validar que tudo compila sem nenhum warning no `-Wall` e que todos os testes passam:



```bash

runghc -Wall -isrc src/Main.hs

runghc -Wall -isrc tests/Testes.hs

```
