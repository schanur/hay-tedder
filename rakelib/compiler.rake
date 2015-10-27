########################################################################
# compiler.rake start
########################################################################

# class COpt
#   @@include_dir = "-Isrc -Isrc/extern/platform/src"
#   # @@link_libs   = "-lm -lGL -lglfw -OpenCL"
#   attr_accessor :include_dir,:link_libs
# end

# class CCompiler
#   def initialize(compiler, warnings)
#     @compiler = compiler
#     @warnings = warnings
#     # @flags    = flags
#   end
#   attr_accessor :compiler,:warnings
# end

# $compiler_list = [:clang =>
#                   CCompiler.new('clang',
#                                 '-Weverything -Wno-padded -Wno-missing-noreturn -Wno-disabled-macro-expansion -Wno-empty-translation-unit',
#                                 ),
#                   :gcc   =>
#                   CCompiler.new('gcc',
#                                 '-Wall -Werror'
#                                 )
#                  ]

# C_COMPILER       = 'clang'

# C_INCLUDE        = "-Isrc -Isrc/extern/platform/src"
# #C_LINK_LIBS      = "-lm -lGL -lglfw -OpenCL"
# C_LINK_SDL2_LIBS = "-L/usr/local/lib -lSDL2 -Wl,-rpath=/usr/local/lib"
# C_LINK_LIBS      = "-lm -lGL -OpenCL " + C_LINK_SDL2_LIBS
# C_LINK           = C_LINK_LIBS
# #C_WARNINGS      = "-Wall"
# #C_WARNINGS      = "-Weverything"
# C_WARNINGS       = "-Weverything -Wno-padded -Wno-missing-noreturn -Wno-disabled-macro-expansion -Wno-empty-translation-unit"
# C_FLAGS          = "#{C_WARNINGS} #{C_INCLUDE}"


########################################################################
# compiler.rake end
########################################################################
