/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

#include "hipo4/utils.h"

namespace hipo {

  utils::utils() {}
  utils::~utils() {}

  void utils::tokenize(const std::string& str, std::vector<std::string>& tokens,
                       const std::string& delimiters) {
    // Skip delimiters at beginning.
    std::string::size_type lastPos = str.find_first_not_of(delimiters, 0);
    // Find first "non-delimiter".
    std::string::size_type pos = str.find_first_of(delimiters, lastPos);

    while (std::string::npos != pos || std::string::npos != lastPos) {
      // Found a token, add it to the vector.
      tokens.push_back(str.substr(lastPos, pos - lastPos));
      // Skip delimiters.  Note the "not_of"
      lastPos = str.find_first_not_of(delimiters, pos);
      // Find next "non-delimiter"
      pos = str.find_first_of(delimiters, lastPos);
    }
  }
  /**
   * finds postion of the dalim in the string, while skipping "order" times.
   */
  int utils::findposition(const std::string& str, const char* delim, int order) {
    int                    found    = 0;
    int                    position = 0;
    std::string::size_type firstPos = str.find_first_of(delim, position);
    if (firstPos == std::string::npos)
      return -1;
    position = firstPos;
    while (found != order) {
      firstPos = str.find_first_of(delim, position + 1);
      if (firstPos == std::string::npos)
        return -1;
      position = firstPos;
      found++;
    }
    return position;
  }
  /**
   * returns a substring from a string that is enclosed between
   * start_delim and end_delim. order variable decides which enclosed
   * string to return as and order of occurance. 0 - first one. 1 - second one.
   */
  std::string utils::substring(const std::string& str, const char* start_delim,
                               const char* end_delim, int order) {
    int position = 0;
    int firstPos = hipo::utils::findposition(str, start_delim, order);
    if (firstPos < 0)
      return std::string();
    std::string::size_type lastPos = str.find_first_of(end_delim, firstPos + 1);
    if (lastPos == std::string::npos)
      return std::string();
    int length = lastPos - firstPos - 1;
    return str.substr(firstPos + 1, length);
  }

  void utils::writeInt(char* buffer, int position, int value) {
    int* ptr = reinterpret_cast<int*>(&buffer[position]);
    *ptr     = value;
  }

  void utils::writeLong(char* buffer, int position, long value) {
    int64_t* ptr = reinterpret_cast<int64_t*>(&buffer[position]);
    *ptr         = value;
  }

  void utils::writeByte(char* buffer, int position, uint8_t value) {
    int8_t* ptr = reinterpret_cast<int8_t*>(&buffer[position]);
    *ptr        = value;
  }

  void utils::printLogo() {
    std::cout << "************************************************" << std::endl;
    std::cout << "*         >=<      :  ---------------------    *" << std::endl;
    std::cout << "*    ,.--'  ''-.   :  HIPO 4.0 I/O Library     *" << std::endl;
    std::cout << "*    (  )  ',_.'   :  Jefferson National Lab   *" << std::endl;
    std::cout << "*     Xx'xX        :  Date: 01/24/2019         *" << std::endl;
    std::cout << "************************************************" << std::endl;
    std::cout << std::endl;
  }

  std::string utils::getHeader() {
    std::string header;
    header.append("//***********************************************************************\n");
    header.append("//***********************************************************************\n");
    header.append("//    ____  ____  _____  _______     ___      ______       __  \n");
    header.append("//   |_   ||   _||_   _||_   __ \\  .'   `.   / ____ `.    /  | \n");
    header.append("//     | |__| |    | |    | |__) |/  .-.  \\  `'  __) |    `| |  \n");
    header.append("//     |  __  |    | |    |  ___/ | |   | |  _  |__ '.     | |  \n");
    header.append("//    _| |  | |_  _| |_  _| |_    \\  `-'  / | \\____) | _  _| |_  \n");
    header.append("//   |____||____||_____||_____|    `.___.'   \\______.'(_)|_____| \n");
    header.append("// \n");
    header.append("//======================================================================= \n");
    header.append("// Autogenerated code by HIPO 3.1 io library\n");
    header.append("// Modify the main loop to suite your needs\n");
    header.append("// Date: \n");
    header.append("//***********************************************************************\n");
    return header;
  }

  std::string utils::getFileHeader() {
    std::string file_header;
    std::string comments = hipo::utils::getHeader();
    file_header.append(comments);
    file_header.append("#include <cstdlib>\n#include <iostream>\n\n");
    file_header.append("#include \"reader.h\"\n#include \"node.h\"\n");
    file_header.append("\nint main(int argc, char** argv) {\n");
    file_header.append("   std::cout << \" reading file example program (HIPO) \" << std::endl;\n");
    file_header.append("   char inputFile[256];\n\n");
    file_header.append("   if(argc>1) {\n      sprintf(inputFile,\"%s\",argv[1]);\n   } else {\n ");
    file_header.append("     std::cout << \" *** please provide a file name...\" << std::endl;\n");
    file_header.append("     exit(0);\n   }\n\n");
    file_header.append("   hipo::reader  reader;\n");
    file_header.append("   reader.open(inputFile);\n\n");
    return file_header;
  }
  std::string utils::getFileTrailer(const char* code) {
    std::string file_trailer;
    file_trailer.append("\n");
    file_trailer.append("   //----------------------------------------------------\n");
    file_trailer.append("   //--  Main LOOP running through events and printing\n");
    file_trailer.append("   //--  values of the first decalred branch\n");
    file_trailer.append("   //----------------------------------------------------\n");
    file_trailer.append("   int entry = 0;\n");
    file_trailer.append("   while(reader.next()==true){\n");
    file_trailer.append("      entry++;\n");
    file_trailer.append("      std::cout << \"event # \" << entry << std::endl;\n");
    file_trailer.append(code);
    file_trailer.append("   }\n");
    file_trailer.append("   //----------------------------------------------------\n");
    file_trailer.append("}\n");
    file_trailer.append("//###### ENF OF GENERATED FILE #######\n");
    return file_trailer;
  }
  std::string utils::getSConstruct() {
    std::string std__string;
    std__string.append("#=================================================\n");
    std__string.append("# The SCONSTRUCT file for building HIPO project.\n");
    std__string.append("# \n");
    std__string.append("#=================================================\n");
    std__string.append("import glob\n");
    std__string.append("import os\n");
    std__string.append("import sys\n");
    std__string.append("#=================================================\n");
    std__string.append("# LOADING THE ENVIRONMENT\n");
    std__string.append("#=================================================\n");
    std__string.append("env = "
                       "Environment(CPPPATH=[\"include\",\".\",\"/usr/include\",\"/usr/local/"
                       "include\",\"/opt/local/include\",\"/group/clas12/packages/lz4/lib\",\"/"
                       "group/clas12/packages/hipo-io/libcpp\"])\n");
    std__string.append("env.Append(ENV = os.environ)\n");
    std__string.append("env.Append(CPPPATH=[\"src/root\",\"src/evio\"])\n");
    std__string.append(
        "env.Append(CCFLAGS=[\"-O2\",\"-fPIC\",\"-m64\",\"-fmessage-length=0\",\"-g\"])\n");
    std__string.append(
        "env.Append(LIBPATH=[\"/opt/local/lib\",\"/usr/lib\",\"/usr/local/lib\",\"/group/clas12/"
        "packages/lz4/lib\",\"lib\",\"/group/clas12/packages/hipo-io/lib\"])\n");
    std__string.append("env.Append(CONFIGUREDIR=[\"/group/clas12/packages/lz4/lib\",\"/group/"
                       "clas12/packages/hipo-io/lib\"])\n");
    std__string.append("#=================================================\n");
    std__string.append("# Check for compression libraries.\n");
    std__string.append("#=================================================\n");
    std__string.append("conf = Configure(env)\n");
    std__string.append("\n");
    std__string.append("if conf.CheckLib('libhipo'):\n");
    std__string.append("   print '\\n\\033[32m[**] >>>>> found library : HIPO'\n");
    std__string.append("   print ''\n");
    std__string.append("   env.Append(CCFLAGS=\"-D__HIPO__\")\n");
    std__string.append("    \n");
    std__string.append("if conf.CheckLib('liblz4'):\n");
    std__string.append("   print '\\n\\033[32m[**] >>>>> found library : LZ4'\n");
    std__string.append("   print '[**] >>>>> enabling lz4 compression. \\033[0m'\n");
    std__string.append("   print ''\n");
    std__string.append("   env.Append(CCFLAGS=\"-D__LZ4__\")\n");
    std__string.append("\n");
    std__string.append("if conf.CheckLib('libz'):\n");
    std__string.append("   print '\\n\\033[32m[**] >>>>> found library : libz'\n");
    std__string.append("   print '[**] >>>>> enabling gzip compression. \\033[0m'\n");
    std__string.append("   print ''\n");
    std__string.append("   env.Append(CCFLAGS=\"-D__LIBZ__\")\n");
    std__string.append("#=================================================\n");
    std__string.append("# BUILDING EXECUTABLE PROGRAM\n");
    std__string.append("#=================================================\n");
    std__string.append(
        "runFileLoop   = env.Program(target=\"runFileLoop\",source=[\"runFileLoop.cc\"])\n");
    return std__string;
  }

  void benchmark::resume() {
    first = clock.now();
    counter++;
  }

  void benchmark::pause() {

    second = clock.now();
    std::chrono::nanoseconds diff_ms =
        std::chrono::duration_cast<std::chrono::nanoseconds>(second - first);
    // printf(" count = %lld\n",diff_ms.count());
    running_time += diff_ms.count();
  }

  long benchmark::getTime() { return running_time; }

  int benchmark::getCounter() { return counter; }
} // namespace hipo
