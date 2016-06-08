/***************************************************************************
                            feature.cpp
                              -------------------
              begin                : 10.12.2014
              copyright            : (C) 2014 by Matthias Kuhn
              email                : matthias (at) opengis.ch
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include "feature.h"

Feature::Feature( const QgsFeature& feature, QgsVectorLayer* layer )
  : mFeature( feature )
  , mLayer( layer )
{
}

Feature::Feature()
  : mLayer( nullptr )
{
}

void Feature::setAttribute( int index, const QVariant& value )
{
  mFeature.setAttribute( index, value );
}

void Feature::setGeometry( const QgsGeometry& geom )
{
  mFeature.setGeometry( geom );
}

void Feature::create()
{
  if ( !mLayer )
    return;

  mLayer->addFeature( mFeature );
}

QString Feature::displayText() const
{
  if ( !mLayer->displayExpression().isEmpty() )
    return QgsExpression( mLayer->displayExpression() ).evaluate( mFeature ).toString();
  else
    return mFeature.attribute( mLayer->displayField() ).toString();
}

bool Feature::readOnly() const
{
  if ( !mLayer )
    return true;

  return mLayer->readOnly();
}

bool Feature::remove()
{
  if ( !mLayer )
    return false;

  mLayer->startEditing();
  mLayer->deleteFeature( mFeature.id() );
  return mLayer->commitChanges();
}
