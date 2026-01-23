

#ifndef PROJECT_GIS_CONVERSIONS_H
#define PROJECT_GIS_CONVERSIONS_H

#if __has_include(<gdal/ogr_spatialref.h>)
  #include <gdal/ogr_spatialref.h>
#else
  #include <ogr_spatialref.h>
#endif

#include "OpenREALM/core/utm32.h"
#include <OpenREALM/core/wgs84.h>

namespace realm
{
namespace gis
{

/*!
 * @brief Converter for a pose (position and heading only) in WGS84 to UTM coordinate frame
 * @param wgs Pose in WGS84 coordinate frame
 * @return Pose in UTM coordinate frame
 */
UTMPose convertToUTM(const WGSPose &wgs);

/*!
 * @brief Converter for a pose (position and heading only) in UTM to WGS84 coordinate frame
 * @param wgs Pose in UTM coordinate frame
 * @return Pose in WGS84 coordinate frame
 */
WGSPose convertToWGS84(const UTMPose &utm);

/*!
 * @brief GDAL 3 changes axis order: https://github.com/OSGeo/gdal/blob/master/gdal/MIGRATION_GUIDE.TXT
 * @param oSRS Spatial reference to be patched depending on the installed GDAL version
 */
void initAxisMappingStrategy(OGRSpatialReference *oSRS);

}
}

#endif //PROJECT_GIS_CONVERSIONS_H
