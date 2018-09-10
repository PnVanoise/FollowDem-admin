"""empty message

Revision ID: 6ccb6f3570dd
Revises: 
Create Date: 2018-09-08 20:56:10.453766

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '6ccb6f3570dd'
down_revision = None
branch_labels = None
depends_on = None
import geoalchemy2

def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('analyses',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('device_id', sa.Integer(), nullable=True),
    sa.Column('gps_date', sa.DateTime(), nullable=True),
    sa.Column('ttf', sa.Integer(), nullable=True),
    sa.Column('x', sa.Float(), nullable=True),
    sa.Column('y', sa.Float(), nullable=True),
    sa.Column('temperature', sa.Integer(), nullable=True),
    sa.Column('sat_number', sa.Integer(), nullable=True),
    sa.Column('hadop', sa.Float(), nullable=True),
    sa.Column('altitude', sa.Integer(), nullable=True),
    sa.Column('geom_mp', geoalchemy2.types.Geometry(geometry_type='POINT'), nullable=True),
    sa.Column('accurate', sa.Boolean(), nullable=True),
    sa.Column('animale_device_id', sa.Integer(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('animal_attributes',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('animal_id', sa.Integer(), nullable=True),
    sa.Column('attribute_id', sa.Integer(), nullable=True),
    sa.Column('value', sa.Text(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('animal_devices',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('animal_id', sa.Integer(), nullable=True),
    sa.Column('device_id', sa.Integer(), nullable=True),
    sa.Column('start_at', sa.DateTime(), nullable=True),
    sa.Column('end_at', sa.DateTime(), nullable=True),
    sa.Column('comment', sa.Text(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('animals',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=50), nullable=False),
    sa.Column('birth_year', sa.DateTime(), nullable=True),
    sa.Column('capture_date', sa.DateTime(), nullable=True),
    sa.Column('death_date', sa.DateTime(), nullable=True),
    sa.Column('comment', sa.Text(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('device_types',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(length=50), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('devices',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('reference', sa.String(length=50), nullable=False),
    sa.Column('device_type_id', sa.Integer(), nullable=False),
    sa.Column('comment', sa.Text(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id', 'device_type_id')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('devices')
    op.drop_table('device_types')
    op.drop_table('animals')
    op.drop_table('animal_devices')
    op.drop_table('animal_attributes')
    op.drop_table('analyses')
    # ### end Alembic commands ###
