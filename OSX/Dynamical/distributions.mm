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
    
std::vector<Bin> binPathsByTime(std::vector<Path> paths, int binCount) {
    // doesn't do anything special yet
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
    
std::vector<Cluster> clusterDBScan(std::vector<Bin> bins) {
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
    
dynam::Mesh *generateMesh(std::vector<Cluster> clusters, int resolution) {
    int indexCount = clusters.size()*resolution*3;
    int vertexCount = clusters.size()*resolution*3;
    GLuint indices[indexCount];
    GLfloat vertices[vertexCount*3];
    
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
    
    return new dynam::Mesh(vertices, indices, indexCount, vertexCount, 3);
}
    
}
