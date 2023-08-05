import os
import re
import bpy

CHARACTERS = re.sub(r"\s+", "", """
    ABCDEFGHIJKLMNOPQRSTUVWXYZ
    abcdefghijklmnopqrstuvwxyz
    0123456789
""")

def indent(text, amount, ch="\t"):
    padding = amount * ch
    return ''.join(padding+line for line in text.splitlines(True))

def remove_collection(collection):
    for obj in collection.objects:
        bpy.data.objects.remove(obj, do_unlink=True)
    
    bpy.data.collections.remove(collection)

def get_lua(fnt, characters):
    entries = []
    
    font = bpy.data.collections.new("FontCollection")
    font.name = "Font"

    bpy.context.scene.collection.children.link(font)

    for character in characters:
        font_curve = bpy.data.curves.new(
            type="FONT",
            name=character + "_FontCurve",
        )
        font_curve.body = character
        font_curve.align_x = "CENTER"
        font_curve.align_y = "CENTER"
        font_curve.font = fnt

        font_obj = bpy.data.objects.new(
            name=character + "_FontObject",
            object_data=font_curve,
        )
        
        font.objects.link(font_obj)
        
        bpy.ops.object.select_all(action='DESELECT')
        bpy.context.view_layer.objects.active = font_obj
        font_obj.select_set(True)
        bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='BOUNDS')
        bpy.ops.object.location_clear()
        bpy.ops.object.convert(target='MESH', keep_original=False)
        
        vertices = []
        faces = []

        mesh = font_obj.data
        mesh.calc_loop_triangles()
        for vertex in mesh.vertices:
            vertices.append("Vector3.new({}, {}, 0),".format(vertex.co[0], vertex.co[1]))
        
        for tri in mesh.loop_triangles:
            faces.append("{{{}, {}, {}}},".format(tri.vertices[0] + 1, tri.vertices[1] + 1, tri.vertices[2] + 1))
        
        size = "Vector3.new({}, {}, 0)".format(font_obj.dimensions.x, font_obj.dimensions.y)
        faces = "{\n" + indent("\n".join(faces), 1) + "\n}"
        vertices = "{\n" + indent("\n".join(vertices), 1) + "\n}"
        
        body = "size = {},\nfaces = {},\nvertices = {},".format(size, faces, vertices)
        entry = "[\"{}\"] = {{\n{}\n}},".format(character, indent(body, 1))
        entries.append(entry)

    remove_collection(font)
    lua = "return {\n" + indent("\n".join(entries), 1) + "\n}"
    
    return lua


# ----------------------------------------------------------------------
# File dialog
from bpy.props import StringProperty, BoolProperty
from bpy_extras.io_utils import ImportHelper
from bpy.types import Operator


class OT_TestOpenFilebrowser(Operator, ImportHelper):

    bl_idname = "test.open_filebrowser"
    bl_label = "Open"
    
    filter_glob: StringProperty(
        default="*.ttf;*.otf;",
        options={"HIDDEN"}
    )

    def execute(self, context):
        """Do something with the selected file(s)."""

        fnt = bpy.data.fonts.load(self.filepath)
        lua = get_lua(fnt, CHARACTERS)
        
        filename = os.path.splitext(os.path.basename(self.filepath))[0] + ".lua"
        new_file = os.path.join(self.filepath, os.path.pardir, filename)
        new_file = os.path.realpath(new_file)
        
        fd = open(new_file, "w")
        fd.write(lua)
        fd.close()
        
        return {'FINISHED'}


def register():
    bpy.utils.register_class(OT_TestOpenFilebrowser)


def unregister():
    bpy.utils.unregister_class(OT_TestOpenFilebrowser)

if __name__ == "__main__":
    register()
    bpy.ops.test.open_filebrowser('INVOKE_DEFAULT')