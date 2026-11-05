module Main (main) where

import Tipos
  ( Linha (..)
  , Partida (..)
  , participou
  , resultadoPara
  , times
  )
import Classificacao
  ( aproveitamento
  , ateRodada
  , classificacao
  , maiorGoleada
  , mediaGols
  )
import Leitura
  ( Erro (..)
  , lerCampeonato
  , tabelaFormatada
  , todosOsErros
  )
import Dados
  ( dadosCampeonato
  , dadosComErros
  , partidasTeste
  )

formatarPartida :: Partida -> String
formatarPartida p =
  "Rodada " ++ show (rodada p) ++ ": "
    ++ mandante p ++ " " ++ show (golsMandante p)
    ++ " x "
    ++ show (golsVisitante p) ++ " " ++ visitante p

formatarErro :: Erro -> String
formatarErro (CamposInvalidos l)      = "Linha " ++ show l ++ ": quantidade de campos invalida ou campo vazio (CamposInvalidos)."
formatarErro (NumeroInvalido l)       = "Linha " ++ show l ++ ": valor numerico invalido para rodada ou placar (NumeroInvalido)."
formatarErro (PlacarNegativo l)       = "Linha " ++ show l ++ ": placar com numero negativo de gols (PlacarNegativo)."
formatarErro (MesmoTime l)            = "Linha " ++ show l ++ ": mandante e visitante sao o mesmo time (MesmoTime)."
formatarErro (TimeRepetidoNaRodada r) = "Rodada " ++ show r ++ ": um mesmo time foi escalado mais de uma vez (TimeRepetidoNaRodada)."

formatarAproveitamento :: Linha -> String
formatarAproveitamento l =
  time l ++ ": " ++ show (fromIntegral (round (aproveitamento l * 100.0) :: Int) / (100.0 :: Double)) ++ "%"

relatorioCamada1 :: [Partida] -> String
relatorioCamada1 ps = unlines
  [ "=== 1. CAMADA 1: TIPOS E CONSULTAS BASICAS ==="
  , "Times participantes (ordem alfabetica): " ++ show (times ps)
  , case ps of
      [] -> "Nenhuma partida cadastrada."
      (p : _) -> unlines
        [ "Primeira partida: " ++ formatarPartida p
        , "Coritiba participou? " ++ show (participou "Coritiba" p)
        , "Resultado para Coritiba: " ++ show (resultadoPara "Coritiba" p)
        , "Resultado para Londrina: " ++ show (resultadoPara "Londrina" p)
        , "Resultado para Cascavel: " ++ show (resultadoPara "Cascavel" p)
        ]
  ]

relatorioEstatisticas :: [Partida] -> String
relatorioEstatisticas ps = unlines
  [ "=== 4. ESTATISTICAS DA CAMADA 2 ==="
  , "Maior goleada: " ++ maybe "Nenhuma partida" formatarPartida (maiorGoleada ps)
  , "Media de gols por partida: " ++ maybe "N/A" show (mediaGols ps)
  , "Aproveitamento por time (classificacao final):"
  , unlines (map (("  - " ++) . formatarAproveitamento) (classificacao ps))
  ]

relatorioCompleto :: String
relatorioCompleto = unlines
  [ relatorioCamada1 partidasTeste
  , "=== 2. CAMADA 3 + CAMADA 2: TABELA FINAL DO CAMPEONATO ==="
  , case lerCampeonato dadosCampeonato of
      Left err -> "Erro ao ler campeonato: " ++ formatarErro err
      Right ps -> unlines
        [ tabelaFormatada (classificacao ps)
        , "=== 3. TABELA INTERMEDIARIA (ATE A 3a RODADA) ==="
        , tabelaFormatada (classificacao (ateRodada 3 ps))
        , relatorioEstatisticas ps
        ]
  , "=== 5. TRATAMENTO DE ENTRADA COM ERROS (CAMADA 3) ==="
  , "5.1 Leitura interrompida no primeiro erro (lerCampeonato):"
  , case lerCampeonato dadosComErros of
      Left err -> "  -> " ++ formatarErro err
      Right _  -> "  -> Nenhum erro encontrado."
  , ""
  , "5.2 Relatorio com todos os erros do texto (todosOsErros):"
  , unlines (map (("  -> " ++) . formatarErro) (todosOsErros dadosComErros))
  ]

main :: IO ()
main = putStrLn relatorioCompleto
