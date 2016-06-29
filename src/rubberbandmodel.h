/***************************************************************************
  rubberbandmodel.h - RubberbandModel

 ---------------------
 begin                : 10.6.2016
 copyright            : (C) 2016 by Matthias Kuhn
 email                : matthias@opengis.ch
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef RUBBERBANDMODEL_H
#define RUBBERBANDMODEL_H

#include <QVector>
#include <QObject>
#include <QPointF>
#include <qgis.h>
#include <qgspoint.h>
#include <qgsabstractgeometryv2.h>

class QgsVectorLayer;

/**
 * This model manages a list of vertices.
 *
 * It can be used as a linestring or as a ring in a polygon.
 */

class RubberbandModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY( QPointF currentCoordinate READ currentCoordinate WRITE setCurrentCoordinate NOTIFY currentCoordinateChanged )
    Q_PROPERTY( int currentCoordinateIndex READ currentCoordinateIndex WRITE setCurrentCoordinateIndex NOTIFY currentCoordinateIndexChanged )
    Q_PROPERTY( QGis::GeometryType geometryType READ geometryType NOTIFY geometryTypeChanged )
    Q_PROPERTY( QgsVectorLayer* vectorLayer READ vectorLayer WRITE setVectorLayer NOTIFY vectorLayerChanged )
    Q_PROPERTY( int vertexCount READ vertexCount NOTIFY vertexCountChanged )

  public:
    explicit RubberbandModel( QObject *parent = 0 );

    int vertexCount() const;

    bool isEmpty() const;

    QVector<QPointF> vertices() const;

    QVector<QgsPoint> flatVertices() const;

    QgsPointSequenceV2 pointSequenceV2() const;

    void setVertex( int index, QPointF coordinate );

    void insertVertices( int index, int count );

    void removeVertices( int index, int count );

    int currentCoordinateIndex() const;
    void setCurrentCoordinateIndex( int currentCoordinateIndex );

    QPointF currentCoordinate() const;
    void setCurrentCoordinate( const QPointF& currentCoordinate );

    Q_INVOKABLE void addVertex();
    Q_INVOKABLE void removeVertex();

    Q_INVOKABLE void reset();

    QGis::GeometryType geometryType() const;

    QgsVectorLayer* vectorLayer() const;
    void setVectorLayer(QgsVectorLayer* vectorLayer);

  signals:
    void vertexChanged( int index );
    void verticesInserted( int index, int count );
    void verticesRemoved( int index, int count );
    void currentCoordinateIndexChanged();
    void currentCoordinateChanged();
    void geometryTypeChanged();
    void vectorLayerChanged();
    void vertexCountChanged();

  private:
    void setGeometryType( const QGis::GeometryType& geometryType );

    QVector<QPointF> mPointList;
    int mCurrentCoordinateIndex;
    QGis::GeometryType mGeometryType;
    QgsVectorLayer* mLayer;
};

#endif // RUBBERBANDMODEL_H
