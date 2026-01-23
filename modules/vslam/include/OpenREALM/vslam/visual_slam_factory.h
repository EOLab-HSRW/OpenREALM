

#ifndef PROJECT_VISUAL_SLAM_FACTORY_H
#define PROJECT_VISUAL_SLAM_FACTORY_H

#include <OpenREALM/core/camera.h>
#include <OpenREALM/core/camera_settings.h>
#include <OpenREALM/core/imu_settings.h>
#include <OpenREALM/vslam/visual_slam_IF.h>
#include <OpenREALM/vslam/visual_slam_settings.h>

namespace realm
{

class VisualSlamFactory
{
  public:
    static VisualSlamIF::Ptr create(const VisualSlamSettings::Ptr &vslam_set, const CameraSettings::Ptr &cam_set, const ImuSettings::Ptr &imu_set = nullptr);
};

}

#endif //PROJECT_VISUAL_SLAM_FACTORY_H
