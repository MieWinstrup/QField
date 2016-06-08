#include "qgssggeometry.h"
extern "C" {
#include "tessellate.h"
}


QgsSGGeometry::QgsSGGeometry()
{
}

QgsSGGeometry::QgsSGGeometry( const QgsGeometry& geom, const QColor& color , int width )
{
  //TODO: Fix const-correcteness upstream
  QgsGeometry& gg = const_cast<QgsGeometry&>( geom );

  mMaterial.setColor( color );

  switch ( gg.type() )
  {
    case QGis::Point:
      if ( gg.isMultipart() )
      {
        const QgsMultiPoint& points = gg.asMultiPoint();

        Q_FOREACH( const QgsPoint& point, points )
        {
          QSGGeometryNode* geomNode = new QSGGeometryNode;
          geomNode->setGeometry( qgsPointToQSGGeometry ( point, width ) );
          geomNode->setFlag( QSGNode::OwnsGeometry );
          applyStyle( geomNode );
          appendChildNode( geomNode );
        }
      }
      else
      {
        QSGGeometryNode* geomNode = new QSGGeometryNode;
        geomNode->setGeometry( qgsPointToQSGGeometry ( gg.asPoint(), width ) );
        geomNode->setFlag( QSGNode::OwnsGeometry );
        applyStyle( geomNode );
        appendChildNode( geomNode );
      }

      break;

    case QGis::Line:
      if ( gg.isMultipart() )
      {
        const QgsMultiPolyline& lines = gg.asMultiPolyline();

        Q_FOREACH( const QgsPolyline& line, lines )
        {
          QSGGeometryNode* geomNode = new QSGGeometryNode;
          geomNode->setGeometry( qgsPolylineToQSGGeometry ( line, width ) );
          geomNode->setFlag( QSGNode::OwnsGeometry );
          applyStyle( geomNode );
          appendChildNode( geomNode );
        }
      }
      else
      {
        QSGGeometryNode* geomNode = new QSGGeometryNode;
        geomNode->setGeometry( qgsPolylineToQSGGeometry ( gg.asPolyline(), width ) );
        geomNode->setFlag( QSGNode::OwnsGeometry );
        applyStyle( geomNode );
        appendChildNode( geomNode );
      }
      break;

    case QGis::Polygon:
      if ( gg.isMultipart() )
      {
        const QgsMultiPolygon& polygons = gg.asMultiPolygon();

        QSGOpacityNode* on = new QSGOpacityNode;
        on->setOpacity( 0.5 );

        Q_FOREACH( const QgsPolygon& polygon, polygons )
        {
          QSGGeometryNode* geomNode = new QSGGeometryNode;
          geomNode->setGeometry( qgsPolygonToQSGGeometry( polygon ) );
          geomNode->setFlag( QSGNode::OwnsGeometry );
          applyStyle( geomNode );
          on->appendChildNode( geomNode );

          geomNode = new QSGGeometryNode;
          geomNode->setGeometry( qgsPolylineToQSGGeometry( polygon.first(), width ) );
          geomNode->setFlag( QSGNode::OwnsGeometry );
          applyStyle( geomNode );
          appendChildNode( geomNode );
        }

        appendChildNode( on );
      }
      else
      {
        QSGOpacityNode* on = new QSGOpacityNode;
        on->setOpacity( 0.5 );
        QSGGeometryNode* geomNode = new QSGGeometryNode;
        geomNode->setGeometry( qgsPolygonToQSGGeometry( gg.asPolygon() ) );
        geomNode->setFlag( QSGNode::OwnsGeometry );
        applyStyle( geomNode );
        on->appendChildNode( geomNode );
        appendChildNode( on );
        geomNode = new QSGGeometryNode;
        geomNode->setGeometry( qgsPolylineToQSGGeometry( gg.asPolygon().first(), width ) );
        geomNode->setFlag( QSGNode::OwnsGeometry );
        applyStyle( geomNode );
        appendChildNode( geomNode );
      }
      break;

    default:
      // Nothing to do
      break;
  }
}

void QgsSGGeometry::applyStyle( QSGGeometryNode* geomNode )
{
  geomNode->setMaterial( &mMaterial );
}

QSGGeometry* QgsSGGeometry::qgsPolylineToQSGGeometry( const QgsPolyline& line , int width )
{
  QSGGeometry* sgGeom = new QSGGeometry( QSGGeometry::defaultAttributes_Point2D(), line.count() );
  QSGGeometry::Point2D* vertices = sgGeom->vertexDataAsPoint2D();

  int i = 0;
  Q_FOREACH( const QgsPoint& pt, line )
  {
    vertices[i].set( pt.x(), pt.y() );
    i++;
  }

  sgGeom->setLineWidth( width );
  sgGeom->setDrawingMode( GL_LINE_STRIP );

  return sgGeom;
}

QSGGeometry* QgsSGGeometry::qgsPolygonToQSGGeometry( const QgsPolygon& polygon )
{
  QgsPolygon::ConstIterator it = polygon.constBegin();

  double* coordinates_out;
  int* tris_out;
  int nverts, ntris;

  const QgsPolyline& ring = *it;

  double* vertices_in = ( double* )malloc( ring.size() * 2 * sizeof( double ) );
  const double* contours_array[] = { vertices_in, vertices_in + ring.size() * 2 };
  int i = 0;

  Q_FOREACH( const QgsPoint &point, ring )
  {
    vertices_in[i++] = point.x();
    vertices_in[i++] = point.y();
  }

  tessellate( &coordinates_out, &nverts,
              &tris_out, &ntris,
              contours_array, contours_array + 2 );

  QSGGeometry* sgGeom = new QSGGeometry( QSGGeometry::defaultAttributes_Point2D(), ntris * 3 );

  QSGGeometry::Point2D* vertices = sgGeom->vertexDataAsPoint2D();

  for ( int j = 0; j < ntris*3; j++ )
  {
    vertices[j].x = coordinates_out[tris_out[j]*2];
    vertices[j].y = coordinates_out[tris_out[j]*2+1];
  }

  free( vertices_in );
  free( coordinates_out );
  free( tris_out );

  sgGeom->setDrawingMode( GL_TRIANGLES );

  return sgGeom;
}

QSGGeometry*QgsSGGeometry::qgsPointToQSGGeometry( const QgsPoint& point, int width )
{
  QSGGeometry* sgGeom = new QSGGeometry( QSGGeometry::defaultAttributes_Point2D(), 1 );

  QSGGeometry::Point2D* vertices = sgGeom->vertexDataAsPoint2D();
  vertices[0].set( point.x(), point.y() );
  sgGeom->setDrawingMode( GL_POINTS );
  sgGeom->setLineWidth( width );

  return sgGeom;
}
