module Dados
  ( dadosCampeonato
  , partidasTeste
  , dadosComErros
  ) where

import Tipos (Partida (..))

dadosCampeonato :: String
dadosCampeonato = unlines
  [ "# rodada;mandante;gols mandante;gols visitante;visitante"
  , ""
  , "# Rodada 1"
  , "1;Coritiba;1;2;Londrina"
  , "1;Athletico;0;1;Cascavel"
  , "1;Maringa;2;1;Operario"
  , ""
  , "# Rodada 2"
  , "2;Coritiba;2;0;Athletico"
  , "2;Operario;0;0;Londrina"
  , "2;Maringa;0;1;Cascavel"
  , ""
  , "# Rodada 3"
  , "3;Coritiba;1;1;Operario"
  , "3;Athletico;2;0;Maringa"
  , "3;Cascavel;2;0;Londrina"
  , ""
  , "# Rodada 4"
  , "4;Athletico;3;0;Operario"
  , "4;Londrina;1;1;Maringa"
  , "4;Cascavel;0;2;Coritiba"
  , ""
  , "# Rodada 5"
  , "5;Maringa;0;1;Coritiba"
  , "5;Londrina;1;2;Athletico"
  , "5;Operario;2;1;Cascavel"
  ]

partidasTeste :: [Partida]
partidasTeste =
  [ Partida 1 "Coritiba"  1 2 "Londrina"
  , Partida 1 "Athletico" 0 1 "Cascavel"
  , Partida 1 "Maringa"   2 1 "Operario"
  , Partida 2 "Coritiba"  2 0 "Athletico"
  , Partida 2 "Operario"  0 0 "Londrina"
  , Partida 2 "Maringa"   0 1 "Cascavel"
  , Partida 3 "Coritiba"  1 1 "Operario"
  , Partida 3 "Athletico" 2 0 "Maringa"
  , Partida 3 "Cascavel"  2 0 "Londrina"
  , Partida 4 "Athletico" 3 0 "Operario"
  , Partida 4 "Londrina"  1 1 "Maringa"
  , Partida 4 "Cascavel"  0 2 "Coritiba"
  , Partida 5 "Maringa"   0 1 "Coritiba"
  , Partida 5 "Londrina"  1 2 "Athletico"
  , Partida 5 "Operario"  2 1 "Cascavel"
  ]

dadosComErros :: String
dadosComErros = unlines
  [ "# Entrada invalida para demonstracao de erros"
  , "1;Coritiba;2;0"
  , "1;Athletico;dois;0;Cascavel"
  , "1;Londrina;-1;2;Maringa"
  , "1;Operario;1;1;Operario"
  , "2;Coritiba;1;0;Athletico"
  , "2;Coritiba;2;2;Londrina"
  ]
