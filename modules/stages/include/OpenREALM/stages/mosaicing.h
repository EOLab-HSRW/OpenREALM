

#ifndef PROJECT_MOSAICING_H
#define PROJECT_MOSAICING_H

#include <deque>
#include <chrono>

#include <OpenREALM/stages/stage_base.h>
#include <OpenREALM/stages/conversions.h>
#include <OpenREALM/stages/stage_settings.h>
#include <OpenREALM/core/frame.h>
#include <OpenREALM/core/cv_grid_map.h>
#include <OpenREALM/core/analysis.h>
#include <OpenREALM/io/cv_export.h>
#include <OpenREALM/io/gis_export.h>
#include <OpenREALM/io/gdal_continuous_writer.h>
#include <OpenREALM/io/mvs_export.h>
#include <OpenREALM/io/utilities.h>
#include <OpenREALM/ortho/delaunay_2d.h>

namespace realm
{
namespace stages
{

class Mosaicing : public StageBase
{
  public:
    using Ptr = std::shared_ptr<Mosaicing>;
    using ConstPtr = std::shared_ptr<const Mosaicing>;

    struct SaveSettings
    {
        bool split_gtiff_channels;
        bool save_ortho_rgb_one;
        bool save_ortho_rgb_all;
        bool save_ortho_gtiff_one;
        bool save_ortho_gtiff_all;
        bool save_elevation_one;
        bool save_elevation_all;
        bool save_elevation_var_one;
        bool save_elevation_var_all;
        bool save_elevation_obs_angle_one;
        bool save_elevation_obs_angle_all;
        bool save_elevation_mesh_one;
        bool save_num_obs_one;
        bool save_num_obs_all;
        bool save_dense_ply;

        bool save_required()
        {
          return split_gtiff_channels || save_ortho_rgb_one || save_ortho_rgb_all ||
                 save_ortho_gtiff_one || save_ortho_gtiff_all || save_elevation_one || save_elevation_all ||
                 save_elevation_var_one || save_elevation_var_all ||
                 save_elevation_obs_angle_one || save_elevation_obs_angle_all ||
                 save_elevation_mesh_one || save_num_obs_one || save_num_obs_all || save_dense_ply;
        }

        bool save_elevation()
        {
          return save_elevation_one || save_elevation_all ||
                 save_elevation_obs_angle_one || save_elevation_obs_angle_all ||
                 save_elevation_var_one || save_elevation_var_all ||
                 save_elevation_mesh_one;
        }

        bool save_ortho()
        {
          return save_ortho_rgb_one || save_ortho_rgb_all || save_ortho_gtiff_one || save_ortho_gtiff_all;
        }

        bool save_nobs()
        {
          return save_num_obs_one || save_num_obs_all;
        }

        bool save_obs_angle()
        {
          return save_elevation_obs_angle_one || save_elevation_obs_angle_all;
        }

        bool save_variance()
        {
          return save_elevation_var_one || save_elevation_var_all;
        }

        bool save_elevation_map()
        {
          return save_elevation_one || save_elevation_all;
        }
    };

  public:
    explicit Mosaicing(const StageSettings::Ptr &stage_set, double rate);
    ~Mosaicing();
    void addFrame(const Frame::Ptr &frame) override;
    bool process() override;
    void runPostProcessing();
    void saveAll();

  private:
    std::deque<Frame::Ptr> m_buffer;
    std::mutex m_mutex_buffer;

    //! Publish of mesh is optional. Set >0 if should be published. Additionally it can be downsampled.
    int m_publish_mesh_nth_iter;
    int m_publish_mesh_every_nth_kf;
    bool m_do_publish_mesh_at_finish;
    double m_downsample_publish_mesh; // [m/pix]

    bool m_use_surface_normals;

    int m_th_elevation_min_nobs;
    float m_th_elevation_var;

    SaveSettings m_settings_save;

    UTMPose::Ptr m_utm_reference;
    CvGridMap::Ptr m_global_map;
    //Delaunay2D::Ptr m_mesher;
    io::GDALContinuousWriter::Ptr m_gdal_writer;

    std::vector<Frame::Ptr> m_frames;

    void finishCallback() override;
    void printSettingsToLog() override;
    uint32_t getQueueDepth() override;

    CvGridMap blend(CvGridMap::Overlap *overlap);

    void reset() override;
    void initStageCallback() override;
    std::vector<Face> createMeshFaces(const CvGridMap::Ptr &map);

    void publish(const Frame::Ptr &frame, const CvGridMap::Ptr &global_map, const CvGridMap::Ptr &update, uint64_t timestamp);

    void saveIter(uint32_t id, const CvGridMap::Ptr &map_update);
    Frame::Ptr getNewFrame();
};

} // namespace stages
} // namespace realm

#endif //PROJECT_MOSAICING_H
