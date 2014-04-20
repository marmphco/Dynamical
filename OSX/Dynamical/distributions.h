//
//  distributions.h
//  Dynamical
//
//  Created by Matthew Jee on 4/19/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#ifndef Dynamical_distributions_h
#define Dynamical_distributions_h

#include <vector>
#include "../../renderer/vector.h"
#include "../../renderer/mesh.h"

namespace dst {

// workflow is:
// paths --bin-> bins --cluster-> clusters --generate_mesh-> mesh for renderer
    
class Point {
public:
    dynam::Vector3 position;
    double time;
};
    
class Cluster {
public:
    std::vector<dynam::Vector3> points;
    dynam::Vector3 center;
    double radius;
};

typedef std::vector<Point> Path;
typedef std::vector<dynam::Vector3> Bin;
    
std::vector<Bin> binPathsByTime(std::vector<Path> paths, size_t binCount);
    
std::vector<Cluster> clusterKMeans(std::vector<Bin> bins);
std::vector<Cluster> clusterDumb(std::vector<Bin> bins);
std::vector<Cluster> clusterDBScan(std::vector<Bin> bins, size_t minPoints, double epsilon);

dynam::Mesh *generateMesh(std::vector<Cluster> clusters, int resolution);

}

#endif
