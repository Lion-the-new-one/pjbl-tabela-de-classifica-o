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
