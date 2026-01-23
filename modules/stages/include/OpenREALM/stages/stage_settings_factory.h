

#ifndef PROJECT_STAGE_SETTINGS_FACTORY_H
#define PROJECT_STAGE_SETTINGS_FACTORY_H

#include <OpenREALM/io/utilities.h>
#include <OpenREALM/stages/stage_settings.h>

namespace realm
{

class StageSettingsFactory
{
  public:
    static StageSettings::Ptr load(const std::string &stage_type_set, const std::string &filepath);
  private:
    template <typename T>
    static StageSettings::Ptr loadDefault(const std::string &stage_type_set, const std::string &filepath);
};

} // namespace realm

#endif //PROJECT_STAGE_SETTINGS_FACTORY_H
