module Tipos
  ( Time
  , Resultado (..)
  , Partida (..)
  , Linha (..)
  , participou
  , resultadoPara
  , times
  ) where

import Data.List (nub, sort)

type Time = String

data Resultado
  = Vitoria
  | Empate
  | Derrota
  deriving (Show, Eq)

data Partida = Partida
  { rodada        :: Int
  , mandante      :: Time
  , golsMandante  :: Int
  , golsVisitante :: Int
  , visitante     :: Time
  } deriving (Show, Eq)

data Linha = Linha
  { time       :: Time
  , jogos      :: Int
  , vitorias   :: Int
  , empates    :: Int
  , derrotas   :: Int
  , golsPro    :: Int
  , golsContra :: Int
  } deriving (Show, Eq)

participou :: Time -> Partida -> Bool
participou t p = t == mandante p || t == visitante p

resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p
  | t == mandante p  = Just (comparaPlacar (golsMandante p) (golsVisitante p))
  | t == visitante p = Just (comparaPlacar (golsVisitante p) (golsMandante p))
  | otherwise        = Nothing
  where
    comparaPlacar :: Int -> Int -> Resultado
    comparaPlacar gp gc
      | gp > gc   = Vitoria
      | gp == gc  = Empate
      | otherwise = Derrota

times :: [Partida] -> [Time]
times ps = sort . nub $ concatMap (\p -> [mandante p, visitante p]) ps
