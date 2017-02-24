#include "geometry.h"

#include <qgspointv2.h>
#include <qgslinestring.h>
#include <qgspolygon.h>
#include <qgsvectorlayer.h>

Geometry::Geometry( QObject* parent )
  : QObject( parent )
{

}

QgsGeometry Geometry::asQgsGeometry() const
{
  QgsAbstractGeometry* geom = nullptr;

  if ( !mVectorLayer )
    return QgsGeometry();

  switch ( mVectorLayer->geometryType() )
  {
    case QgsWkbTypes::PointGeometry:
    {
      geom = new QgsPointV2( mRubberbandModel->currentPoint(  mVectorLayer->crs() ) );
      break;
    }
    case QgsWkbTypes::LineGeometry:
    {
      QgsLineString* line = new QgsLineString();
      line->setPoints( mRubberbandModel->pointSequence( mVectorLayer->crs() ) );
      geom = line;
      break;
    }
    case QgsWkbTypes::PolygonGeometry:
    {
      QgsPolygonV2* polygon = new QgsPolygonV2();
      QgsLineString* ring = new QgsLineString();
      ring->setPoints( mRubberbandModel->pointSequence( mVectorLayer->crs() ) );
      polygon->setExteriorRing( ring );
      geom = polygon;
      break;
    }

    break;
    case QgsWkbTypes::UnknownGeometry:
      break;
    case QgsWkbTypes::NullGeometry:
      break;

  }

  // QgsCoordinateTransform ct( mRubberbandModel->crs(), mVectorLayer->crs() );
  // return ct.transform( QgsGeometry( geom ) );
  return QgsGeometry( geom );
}

RubberbandModel* Geometry::rubberbandModel() const
{
  return mRubberbandModel;
}

void Geometry::setRubberbandModel( RubberbandModel* rubberbandModel )
{
  if ( mRubberbandModel == rubberbandModel )
    return;

  mRubberbandModel = rubberbandModel;

  emit rubberbandModelChanged();
}

void Geometry::applyRubberband()
{
  // TODO: Will need to be implemented for multipart features or polygons with holes.
}

QgsVectorLayer* Geometry::vectorLayer() const
{
  return mVectorLayer;
}

void Geometry::setVectorLayer( QgsVectorLayer* vectorLayer )
{
  if ( mVectorLayer == vectorLayer )
    return;

  mVectorLayer = vectorLayer;
  emit vectorLayerChanged();
}
