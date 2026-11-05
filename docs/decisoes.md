# Decisões de Modelagem e Limitações Conhecidas

## 1. Modelagem de Dados e Estados Inválidos (Camada 1)

### 1.1. Uso de Records em `Partida` e `Linha`
Tanto `Partida` quanto `Linha` foram modelados como registros (*records*) com campos explicitamente nomeados, em vez de tuplas posicionais. Como `Partida` possui três valores do tipo `Int` (`rodada`, `golsMandante`, `golsVisitante`) e dois valores do tipo `Time` (`mandante`, `visitante`), o uso de *records* impede a inversão silenciosa entre gols do mandante e do visitante e gera seletores de projeção claros para as camadas seguintes.

### 1.2. Normalização do Registro `Linha` (Prevenção de Estados Inconsistentes)
O tipo `Linha` armazena exclusivamente os contadores primários acumulados das partidas (`time`, `jogos`, `vitorias`, `empates`, `derrotas`, `golsPro` e `golsContra`). Os valores de pontuação total e saldo de gols não foram incluídos como campos estáticos dentro de `Linha`, sendo derivados pelas funções puras `pontosLinha` e `saldo` na Camada 2. Essa decisão elimina a possibilidade de construir um registro `Linha` em estado inconsistente (por exemplo, um time com 3 vitórias e 0 pontos, ou com 5 gols pró, 2 gols contra e saldo diferente de 3).

### 1.3. Tipo Soma Fechado para `Resultado` e Totalidade em `resultadoPara`
O desfecho de um jogo foi representado pelo tipo algébrico soma `data Resultado = Vitoria | Empate | Derrota`, restringindo o domínio exatamente aos três estados possíveis do esporte e permitindo verificação exaustiva de padrões pelo compilador (`-Wall`). Na função `resultadoPara`, o retorno em `Maybe Resultado` trata diretamente na assinatura o caso em que o time consultado não disputou a partida (`Nothing`), evitando exceções ou valores sentinela.

---

## 2. Funções de Ordem Superior e Dobras (Camada 2)

### 2.1. Escolha entre `foldl` e `foldr`
* **`linhaDoTime` (`foldl`):** A acumulação das estatísticas de um time utiliza `foldl` partindo do estado inicial `Linha t 0 0 0 0 0 0`. Como o acumulador é um registro único atualizado passo a passo à medida que as partidas são processadas na ordem cronológica da lista, a dobra à esquerda expressa naturalmente a transição de estado partida a partida.
* **`maiorGoleada` (`foldl`):** Foi empregada `foldl` com acumulador `Maybe Partida` iniciado em `Nothing`. A escolha do `foldl` garante que, em caso de empate na maior diferença de gols entre duas partidas, a primeira partida cronologicamente encontrada seja preservada (pois a substituição ocorre apenas quando `diferenca p > diferenca atual`).
* **`mediaGols` (`foldr`):** Para a soma do total de gols, utilizou-se `foldr` reduzindo a lista de partidas a um `Int` antes da divisão segura com `fromIntegral`.

### 2.2. Ordenação Multi-critério com o Monóide `Ordering`
Em vez de encadear múltiplas chamadas de `sortBy` (o que seria computacionalmente redundante e propenso a erros de precedência), a função `classificacao` realiza uma única chamada a `sortBy` combinando critérios por meio da instância de `Monoid` do tipo `Ordering` (`<>`), em conjunto com `comparing` e o *newtype* `Down`:
1. Maior pontuação (`Down . pontosLinha`);
2. Maior número de vitórias (`Down . vitorias`);
3. Maior saldo de gols (`Down . saldo`);
4. Maior número de gols pró (`Down . golsPro`);
5. Ordem alfabética crescente do nome do time (`time`).

O operador `<>` avalia os critérios da esquerda para a direita e retorna o primeiro resultado diferente de `EQ`, garantindo código declarativo, conciso e fiel às regras do futebol brasileiro.

### 2.3. Funções Totais e Conversão Numérica Explícita
Nenhuma função parcial da biblioteca padrão (`head`, `maximum`, `foldr1`) foi utilizada. Em campeonatos sem partidas (`[]`), `maiorGoleada` e `mediaGols` devolvem `Nothing`. Em `aproveitamento`, a guarda `jogos l == 0 = 0.0` previne divisão por zero (`NaN`), e `fromIntegral` converte explicitamente os inteiros para `Double` antes da divisão fracionária (`/`).

---

## 3. Validação Monádica e Isolamento de IO (Camada 3)

### 3.1. Uso Conjunto das Mônadas `Maybe` e `Either`
* **`Maybe` na conversão de tipos:** A leitura de inteiros (`lerInt`) evita a função parcial `read` e utiliza `readMaybe` encadeado com o operador monádico `(>>=)` sobre `Just (limpar txt)` e consumido pelo eliminador `maybe`, convertendo `Nothing` em `Left (NumeroInvalido numLinha)`.
* **`Either` com notação `do` e `traverse`:** Em `lerPartida`, todas as regras de validação de uma linha são encadeadas em um bloco `do` na mônada `Either Erro`. A primeira validação que falha retorna `Left`, interrompendo imediatamente o cálculo sem necessidade de expressões `case` aninhadas. Em `lerCampeonato`, a função `traverse` aplica `lerPartida` a todas as linhas úteis e, em seguida, valida a unicidade dos times por rodada, propagando automaticamente o primeiro erro encontrado.
* **Relatório exaustivo em `todosOsErros`:** Como a instância monádica de `Either` possui semântica de curto-circuito (para no primeiro `Left`), a função `todosOsErros` utiliza `map` combinado com `partitionEithers` (`Data.Either`). Isso permite coletar simultaneamente todos os erros individuais de linha e todos os erros de repetição em rodadas a partir das partidas válidas.

### 3.2. Separação entre Núcleo Puro e Casca de IO
Toda a formatação de tabelas e construção dos relatórios de demonstração é realizada por funções puras (`String`). Os dados do campeonato residem em `src/Dados.hs` como constantes puras, eliminando o uso de `getLine` e garantindo execução determinística tanto no GHC local quanto no Haskell Playground. A função `main :: IO ()` limita-se a enviar a `String` consolidada para a saída padrão.

---

## 4. Limitações Conhecidas do Sistema

1. **Curto-circuito por linha em `todosOsErros`:** Embora `todosOsErros` reporte falhas de todas as linhas do texto, cada linha individual é validada por `lerPartida` na mônada `Either`. Assim, se uma mesma linha contiver dois erros simultâneos (por exemplo, placar negativo `-1` e mandante igual ao visitante), apenas o primeiro erro verificado na ordem de validação (`PlacarNegativo`) será reportado para aquela linha específica.
2. **Validação de `TimeRepetidoNaRodada` condicionada a linhas sintaticamente válidas:** Se uma linha da rodada $R$ falhar na análise sintática (por exemplo, por `CamposInvalidos` ou `NumeroInvalido`), ela não gera um valor `Partida`. Consequentemente, a verificação de repetição de times na rodada $R$ considera apenas as linhas que puderam ser convertidas com sucesso em `Partida`.
3. **Comparação literal de nomes de times (*Case Sensitivity* e Acentuação):** Como `Time` é um sinônimo para `String`, a igualdade de nomes (removendo espaços nas extremidades com `limpar`) é sensível a maiúsculas/minúsculas e acentuação. Grafias como `"Operario"`, `"operario"` e `"Operário"` são tratadas como equipes distintas.
4. **Ausência de critérios disciplinares ou confronto direto no desempate:** Caso duas equipes terminem rigorosamente empatadas em pontos, vitórias, saldo de gols e gols pró, o desempate final utiliza a ordem alfabética do nome (`comparing time`), uma vez que o formato de entrada não contempla número de cartões vermelhos/amarelos nem regra de sorteio.
