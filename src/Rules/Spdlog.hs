{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE TypeFamilies #-}

module Rules.Spdlog (spdlogRule) where

import Base
import CMakeBuilder

data Spdlog = Spdlog
  deriving stock (Eq, Show, Typeable, Generic)
  deriving anyclass (Hashable, Binary, NFData)

type instance RuleResult Spdlog = ()

spdlogRule :: Rules ()
spdlogRule = do
  buildSpdlog <-
    useCMake $
      (cmakeBuilder "spdlog")
        { cmakeFlags =
            const
              [ "-DBUILD_SHARED_LIBS=OFF",
                "-DSPDLOG_BUILD_SHARED=OFF",
                "-DSPDLOG_BUILD_PIC=ON",
                "-DSPDLOG_BUILD_EXAMPLE=OFF",
                "-DSPDLOG_BUILD_TESTS=OFF",
                "-DSPDLOG_INSTALL=ON",
                "-DSPDLOG_FMT_EXTERNAL=OFF"
              ],
          preBuild = BuildAction $ \_ src -> do
            cmd_ (Cwd src) "git checkout ."
            cmd_ (Cwd src) "git apply ../patches/spdlog.patch"
        }
  "spdlog" ~> buildWithAndroidEnv buildSpdlog Spdlog
