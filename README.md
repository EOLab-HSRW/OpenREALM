# OpenREALM

This repository is a fork of [OpenREALM](https://github.com/laxnpander/OpenREALM), originally developed by [Alexander K. - Github @laxnpander](https://github.com/laxnpander) as a his master thesis and paper, see [Acknowledgements](#acknowledgements) for more details. It is now maintained by the [EOLab HSRW - Drone Lab](https://www.eolab.de/) (a group focused on drone activities).

<p align="center">
  <img alt="OpenREALM Logo" src="https://github.com/laxnpander/OpenREALM/blob/master/resources/imgs/logo.png?raw=true">
</p>

OpenREALM is a real-time aerial mapping framework.

## Install

Build the repo:
```
git clone https://github.com/laxnpander/OpenREALM.git
cd OpenREALM
cmake -S . -B build
cmake --build build -j
cmake --install build
```

## Acknowledgements


<details>
  <summary>
  If you use OpenREALM for your research, please cite:
  </summary>

```bibkey
@inproceedings{kernOpenREALMRealtimeMapping2020,
  title       = {{{OpenREALM}}: {{Real-time Mapping}} for {{Unmanned Aerial Vehicles}}},
  shorttitle  = {{{OpenREALM}}},
  booktitle   = {2020 {{International Conference}} on {{Unmanned Aircraft Systems}} ({{ICUAS}})},
  author      = {Kern, Alexander and Bobbe, Markus and Khedar, Yogesh and Bestmann, Ulf},
  date        = {2020-09},
  pages       = {902--911},
  publisher   = {IEEE},
  location    = {Athens, Greece},
  doi         = {10.1109/ICUAS48674.2020.9213960},
  url         = {https://ieeexplore.ieee.org/document/9213960/},
  urldate     = {2025-03-26},
  eventtitle  = {2020 {{International Conference}} on {{Unmanned Aircraft Systems}} ({{ICUAS}})},
  isbn        = {978-1-7281-4278-4},
}

@thesis{kernRealtimePhotogrammetryUsing2018,
  type        = {mathesis},
  title       = {Real-Time {{Photogrammetry}} Using Monocular {{SLAM}} for {{Unmanned Aerial Vehicles}}},
  author      = {Kern, Alexander},
  date        = {2018-06-11},
  institution = {Technische Universität Braunschweig},
  location    = {Institute of Flight Guidance, Hermann-Blenk-Straße 27 38108 Braunschweig},
  url         = {https://drive.google.com/file/d/1Xpsdc02y9oKwY50ZrjYIxh_weNuoM-Ww/view},
  urldate     = {2025-03-26},
  langid      = {english},
  pagetotal   = {102}
}

```

</details><br>


<details>
  <summary>Set of publications that from part of the project:</summary>

```
Visual SLAM

[1] Raúl Mur-Artal, J. M. M. Montiel and Juan D. Tardós. ORB-SLAM: A Versatile and Accurate Monocular SLAM System. IEEE Transactions on Robotics, vol. 31, no. 5, pp. 1147-1163, 2015. (2015 IEEE Transactions on Robotics Best Paper Award).

Stereo Reconstruction

[2] Christian Häne, Lionel Heng, Gim Hee Lee, Alexey Sizov, Marc Pollefeys, Real-Time Direct Dense Matching on Fisheye Images Using Plane-Sweeping Stereo, Proc Int. Conf. on 3D Vison (3DV) 2014

Other

[3] P. Fankhauser and M. Hutter, "A Universal Grid Map Library: Implementation and Use Case for Rough Terrain Navigation", in Robot Operating System (ROS) – The Complete Reference (Volume 1), A. Koubaa (Ed.), Springer, 2016.

[4] T. Hinzmann, J. L. Schönberger, M. Pollefeys, and R. Siegwart, "Mapping on the Fly: Real-time 3D Dense Reconstruction, Digital Surface Map and Incremental Orthomosaic Generation for Unmanned Aerial Vehicles"
```

</details><br>
