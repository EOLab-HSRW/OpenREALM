

#ifndef PROJECT_VISUAL_SLAM_FACTORY_H
#define PROJECT_VISUAL_SLAM_FACTORY_H

#include <core/camera.h>
#include <core/camera_settings.h>
#include <core/imu_settings.h>
#include <vslam/visual_slam_IF.h>
#include <vslam/visual_slam_settings.h>

namespace realm
{

class VisualSlamFactory
{
  public:
    static VisualSlamIF::Ptr create(const VisualSlamSettings::Ptr &vslam_set, const CameraSettings::Ptr &cam_set, const ImuSettings::Ptr &imu_set = nullptr);
};

}

#endif //PROJECT_VISUAL_SLAM_FACTORY_H
