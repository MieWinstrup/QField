/***************************************************************************
                            featurelistmodelselection.cpp
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

#include <QDebug>

#include "featurelistmodelselection.h"

FeatureListModelSelection::FeatureListModelSelection( QObject *parent )
  : QObject( parent )
  , mSelection( 0 )
{
}

int FeatureListModelSelection::selection()
{
  if ( mSelection  && mSelection->selectedIndexes().count() )
  {
    return mSelection->selectedIndexes().first().row();
  }
  return -1;
}

void FeatureListModelSelection::setSelection( int selection )
{
  if ( mSelection )
  {
    if ( !mSelection->selectedIndexes().count() || mSelection->selectedIndexes().first().row() != selection )
    {
      mSelection->select( mModel->index( selection, 0 ), QItemSelectionModel::ClearAndSelect );
      emit selectionChanged();
    }
  }
}

FeatureListModel* FeatureListModelSelection::model() const
{
  return mModel;
}

void FeatureListModelSelection::setModel( FeatureListModel* model )
{
  if ( mModel != model )
  {
    delete mSelection;
    mSelection = new QItemSelectionModel( model );
    mModel = model;
    emit modelChanged();
  }
}

const Feature FeatureListModelSelection::selectedFeature() const
{
  if ( mSelection->selectedIndexes().count() )
  {
    return mModel->data( mSelection->selectedIndexes().first(), FeatureListModel::FeatureRole ).value<Feature>();
  }
  return Feature();
}
