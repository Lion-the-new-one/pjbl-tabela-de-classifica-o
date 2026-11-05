module Main (main) where

import Tipos
  ( Linha (..)
  , Partida (..)
  , Resultado (..)
  , participou
  , resultadoPara
  , times
  )
import Classificacao
  ( aproveitamento
  , ateRodada
  , classificacao
  , linhaDoTime
  , maiorGoleada
  , mediaGols
  , pontos
  , pontosLinha
  , saldo
  )
import Leitura
  ( Erro (..)
  , lerCampeonato
  , lerPartida
  , separar
  , todosOsErros
  )
import Dados
  ( dadosCampeonato
  , dadosComErros
  , partidasTeste
  )

testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado
  | obtido == esperado = putStrLn ("OK     " ++ nome)
  | otherwise          = putStrLn ("FALHOU " ++ nome ++ ": " ++ show obtido)

partidaExemplo :: Partida
partidaExemplo = Partida 1 "Coritiba" 1 2 "Londrina"

classificacaoFinalEsperada :: [Linha]
classificacaoFinalEsperada =
  [ Linha "Coritiba"  5 3 1 1 7 3
  , Linha "Athletico" 5 3 0 2 7 4
  , Linha "Cascavel"  5 3 0 2 5 4
  , Linha "Londrina"  5 1 2 2 4 6
  , Linha "Operario"  5 1 2 2 4 7
  , Linha "Maringa"   5 1 1 3 3 6
  ]

classificacaoRodada3Esperada :: [Linha]
classificacaoRodada3Esperada =
  [ Linha "Cascavel"  3 3 0 0 4 0
  , Linha "Coritiba"  3 1 1 1 4 3
  , Linha "Londrina"  3 1 1 1 2 3
  , Linha "Athletico" 3 1 0 2 2 3
  , Linha "Maringa"   3 1 0 2 2 4
  , Linha "Operario"  3 0 2 1 2 3
  ]

partidasDesempateVitorias :: [Partida]
partidasDesempateVitorias =
  [ Partida 1 "TimeA" 1 0 "TimeC"
  , Partida 2 "TimeA" 0 1 "TimeD"
  , Partida 3 "TimeA" 0 1 "TimeC"
  , Partida 1 "TimeB" 1 1 "TimeD"
  , Partida 2 "TimeB" 1 1 "TimeC"
  , Partida 3 "TimeB" 1 1 "TimeD"
  ]

partidasDesempateSaldo :: [Partida]
partidasDesempateSaldo =
  [ Partida 1 "Alfa" 3 0 "Gama"
  , Partida 1 "Beta" 1 0 "Gama"
  ]

partidasDesempateGolsPro :: [Partida]
partidasDesempateGolsPro =
  [ Partida 1 "Alfa" 2 1 "Gama"
  , Partida 1 "Beta" 3 2 "Delta"
  ]

testesCamada1 :: IO ()
testesCamada1 = do
  putStrLn "=== TESTES CAMADA 1 ==="
  testar "participou (mandante)"
    (participou "Coritiba" partidaExemplo)
    True
  testar "participou (visitante)"
    (participou "Londrina" partidaExemplo)
    True
  testar "participou (time ausente)"
    (participou "Cascavel" partidaExemplo)
    False
  testar "resultadoPara (mandante derrotado)"
    (resultadoPara "Coritiba" partidaExemplo)
    (Just Derrota)
  testar "resultadoPara (visitante vencedor)"
    (resultadoPara "Londrina" partidaExemplo)
    (Just Vitoria)
  testar "resultadoPara (empate 0x0)"
    (resultadoPara "Operario" (Partida 2 "Operario" 0 0 "Londrina"))
    (Just Empate)
  testar "resultadoPara (time que nao jogou a partida)"
    (resultadoPara "Cascavel" partidaExemplo)
    Nothing
  testar "times do campeonato de teste (sem repeticao e em ordem alfabetica)"
    (times partidasTeste)
    ["Athletico", "Cascavel", "Coritiba", "Londrina", "Maringa", "Operario"]
  testar "times sobre lista vazia"
    (times [])
    []

testesCamada2 :: IO ()
testesCamada2 = do
  putStrLn "\n=== TESTES CAMADA 2 ==="
  testar "pontos Vitoria, Empate e Derrota"
    [pontos Vitoria, pontos Empate, pontos Derrota]
    [3, 1, 0]
  testar "linhaDoTime acumulada para Coritiba"
    (linhaDoTime partidasTeste "Coritiba")
    (Linha "Coritiba" 5 3 1 1 7 3)
  testar "pontosLinha e saldo do lider"
    (pontosLinha (Linha "Coritiba" 5 3 1 1 7 3), saldo (Linha "Coritiba" 5 3 1 1 7 3))
    (10, 4)
  testar "aproveitamento de time sem jogos (divisao segura)"
    (aproveitamento (Linha "SemJogos" 0 0 0 0 0 0))
    0.0
  testar "aproveitamento de time com 100% (3 vitorias em 3 jogos)"
    (aproveitamento (Linha "Cascavel" 3 3 0 0 4 0))
    100.0
  testar "classificacao final completa do campeonato de teste"
    (classificacao partidasTeste)
    classificacaoFinalEsperada
  testar "classificacao ateRodada 3 (diferente da classificacao final)"
    (classificacao (ateRodada 3 partidasTeste))
    classificacaoRodada3Esperada
  testar "diferenca entre classificacao ateRodada 3 e classificacao final"
    (classificacao (ateRodada 3 partidasTeste) /= classificacao partidasTeste)
    True
  testar "desempate em pontos (9 pts) decidido por saldo de gols (Athletico +3 vs Cascavel +1)"
    (map time (take 3 (classificacao partidasTeste)))
    ["Coritiba", "Athletico", "Cascavel"]
  testar "desempate em pontos (3 pts) decidido por numero de vitorias (TimeA 1V vs TimeB 0V)"
    (take 2 (map time (classificacao partidasDesempateVitorias)))
    ["TimeA", "TimeB"]
  testar "desempate em pontos e vitorias decidido por saldo de gols (Alfa +3 vs Beta +1)"
    (take 2 (map time (classificacao partidasDesempateSaldo)))
    ["Alfa", "Beta"]
  testar "desempate em pontos, vitorias e saldo decidido por gols pro (Beta 3 GP vs Alfa 2 GP)"
    (take 2 (map time (classificacao partidasDesempateGolsPro)))
    ["Beta", "Alfa"]
  testar "maiorGoleada em lista vazia devolve Nothing"
    (maiorGoleada [])
    Nothing
  testar "maiorGoleada no campeonato de teste (Athletico 3x0 Operario)"
    (maiorGoleada partidasTeste)
    (Just (Partida 4 "Athletico" 3 0 "Operario"))
  testar "mediaGols em lista vazia devolve Nothing"
    (mediaGols [])
    Nothing
  testar "mediaGols no campeonato de teste (30 gols em 15 jogos = 2.0)"
    (mediaGols partidasTeste)
    (Just 2.0)

testesCamada3 :: IO ()
testesCamada3 = do
  putStrLn "\n=== TESTES CAMADA 3 ==="
  testar "separar campos por ponto e virgula"
    (separar ';' "1;Coritiba;2;1;Athletico")
    ["1", "Coritiba", "2", "1", "Athletico"]
  testar "lerCampeonato sobre entrada valida devolve Right"
    (lerCampeonato dadosCampeonato)
    (Right partidasTeste)
  testar "construtor Erro: CamposInvalidos (faltando campos)"
    (lerPartida 1 "1;Coritiba;2;0")
    (Left (CamposInvalidos 1))
  testar "construtor Erro: NumeroInvalido (placar nao numerico 'dois')"
    (lerPartida 2 "1;Athletico;dois;0;Cascavel")
    (Left (NumeroInvalido 2))
  testar "construtor Erro: PlacarNegativo (gols negativos)"
    (lerPartida 3 "1;Londrina;-1;2;Maringa")
    (Left (PlacarNegativo 3))
  testar "construtor Erro: MesmoTime (time jogando contra si mesmo)"
    (lerPartida 4 "1;Operario;1;1;Operario")
    (Left (MesmoTime 4))
  testar "construtor Erro: TimeRepetidoNaRodada (mesmo time duas vezes na rodada 2)"
    (lerCampeonato "2;Coritiba;1;0;Athletico\n2;Coritiba;2;2;Londrina")
    (Left (TimeRepetidoNaRodada 2))
  testar "todosOsErros sobre texto com multiplas linhas invalidas"
    (todosOsErros dadosComErros)
    [ CamposInvalidos 2
    , NumeroInvalido 3
    , PlacarNegativo 4
    , MesmoTime 5
    , TimeRepetidoNaRodada 2
    ]

main :: IO ()
main = do
  testesCamada1
  testesCamada2
  testesCamada3
