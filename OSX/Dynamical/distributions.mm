//
//  distributions.c
//  Dynamical
//
//  Created by Matthew Jee on 4/19/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#include "distributions.h"

// real stuff starts here

namespace dst {
    
std::vector<Bin> binPathsByTime(std::vector<Path> paths, size_t binCount) {
    // doesn't do anything special yet, just assumes uniform time steps
    // for now binCount should be equal to paths[i].size()
    std::vector<Bin> bins(binCount, Bin(paths.size(), dynam::Vector3()));
    for (int binIndex = 0; binIndex < binCount; ++binIndex) {
        for (int pathIndex = 0; pathIndex < paths.size(); ++pathIndex) {
            Point p = paths[pathIndex][binIndex];
            bins[binIndex][pathIndex] = dynam::Vector3(p.position.x, p.position.y, p.position.z);
        }
    }
    return bins;
}
    
std::vector<Cluster> clusterDumb(std::vector<Bin> bins) {
    std::vector<Cluster> clusters;
    // just sticks everything in one cluster
    for (int binIndex = 0; binIndex < bins.size(); ++binIndex) {
        Bin bin = bins[binIndex];
        Cluster cluster;
        for (int i = 0; i < bin.size(); ++i) {
            cluster.points.push_back(bin[i]);
        }
        cluster.radius = 0;
        for (int i = 0; i < cluster.points.size(); ++i) {
            for (int j = i; j < cluster.points.size(); ++j) {
                double dist = (cluster.points[i]-cluster.points[j]).length();
                if (dist > cluster.radius*2) {
                    cluster.center = (cluster.points[i]+cluster.points[j])*(0.5);
                    cluster.radius = dist/2;
                }
            }
        }
        clusters.push_back(cluster);
    }
    return clusters;
}
    
// returns indices of points corresponding to points in the epsilon neighborhood of p
std::vector<int> epsilonNeighborhood(std::vector<dynam::Vector3> points, dynam::Vector3 p, double epsilon) {
    std::vector<int> neighborhood;
    for (int i = 0; i < points.size(); ++i) {
        dynam::Vector3 q = points[i];
        if ((p-q).length() <= epsilon) {
            neighborhood.push_back(i);
        }
    }
    return neighborhood;
}

// O(n^2) implementation of DBScan
std::vector<Cluster> clusterDBScan(std::vector<Bin> bins, size_t minPoints, double epsilon) {
    std::vector<Cluster> clusters;
    // just sticks everything in one cluster
    for (int binIndex = 0; binIndex < bins.size(); ++binIndex) {
        Bin bin = bins[binIndex];
        size_t count = bin.size();
        
        //initialize
        bool visited[count];
        size_t cluster[count];
        for (int i = 0; i < count; i++) {
            visited[i] = false;
            cluster[i] = -1; // no cluster assigned
        }
        // do DBSCAN!
        for (int i = 0; i < count; ++i) {
            dynam::Vector3 p = bin[i];
            if (!visited[i]) {
                visited[i] = true;
                std::vector<int> neighborhood = epsilonNeighborhood(bin, p, epsilon);
                if (neighborhood.size() < minPoints) {
                    cluster[i] = -1;
                } else {

                    clusters.push_back(Cluster());
                    //expand cluster
                    size_t clusterIndex = clusters.size()-1;
                    cluster[i] = clusterIndex;
                    clusters[clusterIndex].points.push_back(p);
                    for (int j = 0; j < neighborhood.size(); ++j) {
                        int q = neighborhood[j];
                        if (!visited[q]) {
                            visited[q] = true;
                            std::vector<int> qNeighborhood = epsilonNeighborhood(bin, bin[q], epsilon);
                            if (qNeighborhood.size() >= minPoints) {
                                neighborhood.insert(neighborhood.end(), qNeighborhood.begin(), qNeighborhood.end());
                            }
                        }
                        if (cluster[q] == -1) {
                            cluster[q] = clusterIndex;
                            clusters[clusterIndex].points.push_back(bin[q]);
                        }
                    }
                }
            }
        }
    }
    for (int k = 0; k < clusters.size(); ++k) {
        // calculate cluster center and radius
        Cluster *cluster = &clusters[k];
        cluster->radius = 0;
        for (int i = 0; i < cluster->points.size(); ++i) {
            for (int j = i; j < cluster->points.size(); ++j) {
                double dist = (cluster->points[i]-cluster->points[j]).length();
                if (dist > cluster->radius*2) {
                    cluster->center = (cluster->points[i]+cluster->points[j])*(0.5);
                    cluster->radius = dist/2;
                }
            }
        }
    }
    return clusters;
}
    
dynam::Mesh *generateMesh(std::vector<Cluster> clusters, int resolution) {
    int indexCount = clusters.size()*resolution*3;
    int vertexCount = clusters.size()*resolution*3;

    GLuint *indices = new GLuint[indexCount];
    GLfloat *vertices = new GLfloat[vertexCount*3];
    
    for (int i = 0; i < clusters.size(); i++) {
        Cluster *cluster = &clusters[i];
        GLfloat x = cluster->center.x;
        GLfloat y = cluster->center.y;
        GLfloat r = cluster->radius;
        int base = i*resolution*3*3;
        // add one triangle for each 'res'
        for (int j = 0; j < resolution; j++) {
            GLfloat theta1 = j*1.0/resolution*M_PI*2;
            GLfloat theta2 = (j+1)*1.0/resolution*M_PI*2;
            
            vertices[base+j*3*3] = x;
            vertices[base+j*3*3+1] = y;
            vertices[base+j*3*3+2] = 0;
            
            vertices[base+j*3*3+3] = x+cosf(theta1)*r;
            vertices[base+j*3*3+4] = y+sinf(theta1)*r;
            vertices[base+j*3*3+5] = 0;
            
            vertices[base+j*3*3+6] = x+cosf(theta2)*r;
            vertices[base+j*3*3+7] = y+sinf(theta2)*r;
            vertices[base+j*3*3+8] = 0;
        }
    }
    
    for (int i = 0; i < indexCount; ++i) {
        indices[i] = i;
    }
    
    dynam::Mesh *mesh = new dynam::Mesh(vertices, indices, indexCount, vertexCount, 3);
    delete vertices;
    delete indices;
    
    return mesh;
}
    
}
