module Leitura
  ( Erro (..)
  , separar
  , lerPartida
  , lerCampeonato
  , todosOsErros
  , tabelaFormatada
  ) where

import Data.Char (isSpace)
import Data.Either (partitionEithers)
import Data.List (dropWhileEnd, intercalate, nub)
import Text.Read (readMaybe)
import Tipos
import Classificacao (pontosLinha, saldo)

data Erro
  = CamposInvalidos Int
  | NumeroInvalido Int
  | PlacarNegativo Int
  | MesmoTime Int
  | TimeRepetidoNaRodada Int
  deriving (Show, Eq)

separar :: Char -> String -> [String]
separar delim str = case break (== delim) str of
  (parte, [])     -> [parte]
  (parte, _ : xs) -> parte : separar delim xs

limpar :: String -> String
limpar = dropWhileEnd isSpace . dropWhile isSpace

lerInt :: Int -> String -> Either Erro Int
lerInt numLinha txt =
  maybe (Left (NumeroInvalido numLinha)) Right (Just (limpar txt) >>= readMaybe)

extrairCampos :: Int -> [String] -> Either Erro (String, String, String, String, String)
extrairCampos numLinha [r, m, gm, gv, v]
  | any null [r, m, gm, gv, v] = Left (CamposInvalidos numLinha)
  | otherwise                  = Right (r, m, gm, gv, v)
extrairCampos numLinha _ = Left (CamposInvalidos numLinha)

validarRodadaPositiva :: Int -> Int -> Either Erro ()
validarRodadaPositiva numLinha r
  | r <= 0    = Left (NumeroInvalido numLinha)
  | otherwise = Right ()

validarPlacar :: Int -> Int -> Int -> Either Erro ()
validarPlacar numLinha gm gv
  | gm < 0 || gv < 0 = Left (PlacarNegativo numLinha)
  | otherwise        = Right ()

validarTimesDistintos :: Int -> Time -> Time -> Either Erro ()
validarTimesDistintos numLinha m v
  | m == v    = Left (MesmoTime numLinha)
  | otherwise = Right ()

lerPartida :: Int -> String -> Either Erro Partida
lerPartida numLinha linha = do
  let campos = map limpar (separar ';' linha)
  (sRod, sMand, sGM, sGV, sVis) <- extrairCampos numLinha campos
  rod <- lerInt numLinha sRod
  gm  <- lerInt numLinha sGM
  gv  <- lerInt numLinha sGV
  validarRodadaPositiva numLinha rod
  validarPlacar numLinha gm gv
  validarTimesDistintos numLinha sMand sVis
  Right (Partida rod sMand gm gv sVis)

linhasUteis :: String -> [(Int, String)]
linhasUteis texto = filter (not . ehIgnorada . snd) (zip [1 ..] (lines texto))
  where
    ehIgnorada :: String -> Bool
    ehIgnorada s = case dropWhile isSpace s of
      []        -> True
      ('#' : _) -> True
      _         -> False

rodadasUnicas :: [Partida] -> [Int]
rodadasUnicas ps = nub (map rodada ps)

verificarRodada :: [Partida] -> Int -> Either Erro ()
verificarRodada ps r
  | temRepetido timesNaRodada = Left (TimeRepetidoNaRodada r)
  | otherwise                 = Right ()
  where
    partidasDaRodada :: [Partida]
    partidasDaRodada = filter (\p -> rodada p == r) ps

    timesNaRodada :: [Time]
    timesNaRodada = concatMap (\p -> [mandante p, visitante p]) partidasDaRodada

    temRepetido :: [Time] -> Bool
    temRepetido xs = length xs /= length (nub xs)

lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  partidas <- traverse (uncurry lerPartida) (linhasUteis texto)
  _ <- traverse (verificarRodada partidas) (rodadasUnicas partidas)
  Right partidas

todosOsErros :: String -> [Erro]
todosOsErros texto = errosLinhas ++ errosRodadas
  where
    (errosLinhas, partidasValidas) =
      partitionEithers (map (uncurry lerPartida) (linhasUteis texto))
    (errosRodadas, _) =
      partitionEithers (map (verificarRodada partidasValidas) (rodadasUnicas partidasValidas))

tabelaFormatada :: [Linha] -> String
tabelaFormatada linhas = unlines (cabecalho : separador : zipWith formatarLinha [1 ..] linhas)
  where
    larguraTime :: Int
    larguraTime = foldl max 12 (map (length . time) linhas)

    alinharEsq :: Int -> String -> String
    alinharEsq n s = s ++ replicate (max 0 (n - length s)) ' '

    alinharDir :: Int -> String -> String
    alinharDir n s = replicate (max 0 (n - length s)) ' ' ++ s

    cabecalho :: String
    cabecalho = intercalate " | "
      [ alinharDir 3 "Pos"
      , alinharEsq larguraTime "Time"
      , alinharDir 3 "Pts"
      , alinharDir 2 "J"
      , alinharDir 2 "V"
      , alinharDir 2 "E"
      , alinharDir 2 "D"
      , alinharDir 3 "GP"
      , alinharDir 3 "GC"
      , alinharDir 4 "SG"
      ]

    separador :: String
    separador = replicate (length cabecalho) '-'

    formatarLinha :: Int -> Linha -> String
    formatarLinha pos l = intercalate " | "
      [ alinharDir 3 (show pos)
      , alinharEsq larguraTime (time l)
      , alinharDir 3 (show (pontosLinha l))
      , alinharDir 2 (show (jogos l))
      , alinharDir 2 (show (vitorias l))
      , alinharDir 2 (show (empates l))
      , alinharDir 2 (show (derrotas l))
      , alinharDir 3 (show (golsPro l))
      , alinharDir 3 (show (golsContra l))
      , alinharDir 4 (show (saldo l))
      ]
