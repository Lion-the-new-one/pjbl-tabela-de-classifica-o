module Classificacao
  ( pontos
  , linhaDoTime
  , pontosLinha
  , saldo
  , aproveitamento
  , classificacao
  , ateRodada
  , maiorGoleada
  , mediaGols
  ) where

import Data.List (sortBy)
import Data.Ord (Down (..), comparing)
import Tipos

pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime ps t = foldl acumular (Linha t 0 0 0 0 0 0) ps
  where
    acumular :: Linha -> Partida -> Linha
    acumular lin p = case resultadoPara t p of
      Nothing -> lin
      Just res ->
        let (gp, gc) = golsNaPartida t p
            v = if res == Vitoria then 1 else 0
            e = if res == Empate  then 1 else 0
            d = if res == Derrota then 1 else 0
        in lin
             { jogos      = jogos lin + 1
             , vitorias   = vitorias lin + v
             , empates    = empates lin + e
             , derrotas   = derrotas lin + d
             , golsPro    = golsPro lin + gp
             , golsContra = golsContra lin + gc
             }

    golsNaPartida :: Time -> Partida -> (Int, Int)
    golsNaPartida tm part
      | tm == mandante part = (golsMandante part, golsVisitante part)
      | otherwise           = (golsVisitante part, golsMandante part)

pontosLinha :: Linha -> Int
pontosLinha l =
  vitorias l * pontos Vitoria
    + empates l * pontos Empate
    + derrotas l * pontos Derrota

saldo :: Linha -> Int
saldo l = golsPro l - golsContra l

aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0.0
  | otherwise    = (fromIntegral (pontosLinha l) / fromIntegral (jogos l * 3)) * 100.0

classificacao :: [Partida] -> [Linha]
classificacao ps = (sortBy criterioDesempate . map (linhaDoTime ps)) (times ps)
  where
    criterioDesempate :: Linha -> Linha -> Ordering
    criterioDesempate =
          comparing (Down . pontosLinha)
       <> comparing (Down . vitorias)
       <> comparing (Down . saldo)
       <> comparing (Down . golsPro)
       <> comparing time

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada r = filter (\p -> rodada p <= r)

maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada = foldl escolherMaior Nothing
  where
    diferenca :: Partida -> Int
    diferenca p = abs (golsMandante p - golsVisitante p)

    escolherMaior :: Maybe Partida -> Partida -> Maybe Partida
    escolherMaior Nothing p = Just p
    escolherMaior (Just atual) p
      | diferenca p > diferenca atual = Just p
      | otherwise                     = Just atual

mediaGols :: [Partida] -> Maybe Double
mediaGols [] = Nothing
mediaGols ps = Just (fromIntegral totalGols / fromIntegral (length ps))
  where
    totalGols :: Int
    totalGols = foldr (\p acc -> golsMandante p + golsVisitante p + acc) 0 ps
