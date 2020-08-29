#pragma once

#include "c8-option-parser/errors/Error.hpp"

namespace C8::OptionParser::Errors {
  struct InvalidOptionNameError : public C8::OptionParser::Errors::Error {
    explicit InvalidOptionNameError(std::string_view);
  };
} // namespace C8::OptionParser::Errors
