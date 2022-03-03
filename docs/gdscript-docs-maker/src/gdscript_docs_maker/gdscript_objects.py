"""Converts the json representation of GDScript classes as dictionaries into objects
"""
import itertools
import operator
import re
from dataclasses import dataclass
from enum import Enum
from operator import itemgetter
from typing import List, Tuple

from .make_markdown import make_bold, make_code_inline, make_list, surround_with_html
from .utils import build_re_pattern

BUILTIN_VIRTUAL_CALLBACKS = [
    "_process",
    "_physics_process",
    "_input",
    "_unhandled_input",
    "_gui_input",
    "_draw",
    "_get_configuration_warning",
    "_ready",
    "_enter_tree",
    "_exit_tree",
    "_get",
    "_get_property_list",
    "_notification",
    "_set",
    "_to_string",
    "_clips_input",
    "_get_minimum_size",
    "_gui_input",
    "_make_custom_tooltip",
]

TYPE_CONSTRUCTOR = "_init"

BUILTIN_CLASSES = [
    "aabb","acceptdialog","aescontext","animatedsprite","animatedsprite3d","animatedtexture","animation","animationnode","animationnodeadd2","animationnodeadd3","animationnodeanimation","animationnodeblend2","animationnodeblend3","animationnodeblendspace1d","animationnodeblendspace2d","animationnodeblendtree","animationnodeoneshot","animationnodeoutput","animationnodestatemachine","animationnodestatemachineplayback","animationnodestatemachinetransition","animationnodetimescale","animationnodetimeseek","animationnodetransition","animationplayer","animationrootnode","animationtrackeditplugin","animationtree","animationtreeplayer","area","area2d","array","arraymesh","arvranchor","arvrcamera","arvrcontroller","arvrinterface","arvrinterfacegdnative","arvrorigin","arvrpositionaltracker","arvrserver","aspectratiocontainer","astar","astar2d","atlastexture","audiobuslayout","audioeffect","audioeffectamplify","audioeffectbandlimitfilter","audioeffectbandpassfilter","audioeffectcapture","audioeffectchorus","audioeffectcompressor","audioeffectdelay","audioeffectdistortion","audioeffecteq","audioeffecteq10","audioeffecteq21","audioeffecteq6","audioeffectfilter","audioeffecthighpassfilter","audioeffecthighshelffilter","audioeffectinstance","audioeffectlimiter","audioeffectlowpassfilter","audioeffectlowshelffilter","audioeffectnotchfilter","audioeffectpanner","audioeffectphaser","audioeffectpitchshift","audioeffectrecord","audioeffectreverb","audioeffectspectrumanalyzer","audioeffectspectrumanalyzerinstance","audioeffectstereoenhance","audioserver","audiostream","audiostreamgenerator","audiostreamgeneratorplayback","audiostreammicrophone","audiostreammp3","audiostreamoggvorbis","audiostreamplayback","audiostreamplaybackresampled","audiostreamplayer","audiostreamplayer2d","audiostreamplayer3d","audiostreamrandompitch","audiostreamsample","backbuffercopy","bakedlightmap","bakedlightmapdata","basebutton","basis","bitmap","bitmapfont","bone2d","boneattachment","bool","boxcontainer","boxshape","button","buttongroup","camera","camera2d","camerafeed","cameraserver","cameratexture","canvasitem","canvasitemmaterial","canvaslayer","canvasmodulate","capsulemesh","capsuleshape","capsuleshape2d","centercontainer","charfxtransform","checkbox","checkbutton","circleshape2d","classdb","clippedcamera","collisionobject","collisionobject2d","collisionpolygon","collisionpolygon2d","collisionshape","collisionshape2d","color","colorpicker","colorpickerbutton","colorrect","concavepolygonshape","concavepolygonshape2d","conetwistjoint","configfile","confirmationdialog","container","control","convexpolygonshape","convexpolygonshape2d","cpuparticles","cpuparticles2d","crypto","cryptokey","csgbox","csgcombiner","csgcylinder","csgmesh","csgpolygon","csgprimitive","csgshape","csgsphere","csgtorus","csharpscript","cubemap","cubemesh","cullinstance","curve","curve2d","curve3d","curvetexture","cylindermesh","cylindershape","dampedspringjoint2d","dictionary","directionallight","directory","dtlsserver","dynamicfont","dynamicfontdata","editorexportplugin","editorfeatureprofile","editorfiledialog","editorfilesystem","editorfilesystemdirectory","editorimportplugin","editorinspector","editorinspectorplugin","editorinterface","editornavigationmeshgenerator","editorplugin","editorproperty","editorresourceconversionplugin","editorresourcepicker","editorresourcepreview","editorresourcepreviewgenerator","editorsceneimporter","editorsceneimporterfbx","editorsceneimportergltf","editorscenepostimport","editorscript","editorscriptpicker","editorselection","editorsettings","editorspatialgizmo","editorspatialgizmoplugin","editorspinslider","editorvcsinterface","encodedobjectasid","engine","environment","expression","externaltexture","file","filedialog","filesystemdock","float","font","funcref","gdnative","gdnativelibrary","gdscript","gdscriptfunctionstate","generic6dofjoint","geometry","geometryinstance","giprobe","giprobedata","gltfaccessor","gltfanimation","gltfbufferview","gltfcamera","gltfdocument","gltflight","gltfmesh","gltfnode","gltfskeleton","gltfskin","gltfspecgloss","gltfstate","gltftexture","godotsharp","gradient","gradienttexture","graphedit","graphnode","gridcontainer","gridmap","groovejoint2d","hashingcontext","hboxcontainer","heightmapshape","hingejoint","hmaccontext","hscrollbar","hseparator","hslider","hsplitcontainer","httpclient","httprequest","image","imagetexture","immediategeometry","input","inputevent","inputeventaction","inputeventgesture","inputeventjoypadbutton","inputeventjoypadmotion","inputeventkey","inputeventmagnifygesture","inputeventmidi","inputeventmouse","inputeventmousebutton","inputeventmousemotion","inputeventpangesture","inputeventscreendrag","inputeventscreentouch","inputeventwithmodifiers","inputmap","instanceplaceholder","int","interpolatedcamera","ip","itemlist","javaclass","javaclasswrapper","javascript","javascriptobject","jnisingleton","joint","joint2d","json","jsonparseresult","jsonrpc","kinematicbody","kinematicbody2d","kinematiccollision","kinematiccollision2d","label","largetexture","light","light2d","lightoccluder2d","line2d","lineedit","lineshape2d","linkbutton","listener","listener2d","mainloop","margincontainer","marshalls","material","menubutton","mesh","meshdatatool","meshinstance","meshinstance2d","meshlibrary","meshtexture","mobilevrinterface","multimesh","multimeshinstance","multimeshinstance2d","multiplayerapi","multiplayerpeergdnative","mutex","nativescript","navigation","navigation2d","navigationmesh","navigationmeshinstance","navigationpolygon","navigationpolygoninstance","networkedmultiplayerenet","networkedmultiplayerpeer","ninepatchrect","node","node2d","nodepath","noisetexture","object","occluder","occluderpolygon2d","occludershape","occludershapesphere","omnilight","opensimplexnoise","optionbutton","os","packeddatacontainer","packeddatacontainerref","packedscene","packedscenegltf","packetpeer","packetpeerdtls","packetpeergdnative","packetpeerstream","packetpeerudp","panel","panelcontainer","panoramasky","parallaxbackground","parallaxlayer","particles","particles2d","particlesmaterial","path","path2d","pathfollow","pathfollow2d","pckpacker","performance","phashtranslation","physicalbone","physics2ddirectbodystate","physics2ddirectspacestate","physics2dserver","physics2dshapequeryparameters","physics2dtestmotionresult","physicsbody","physicsbody2d","physicsdirectbodystate","physicsdirectspacestate","physicsmaterial","physicsserver","physicsshapequeryparameters","physicstestmotionresult","pinjoint","pinjoint2d","plane","planemesh","planeshape","pluginscript","pointmesh","polygon2d","polygonpathfinder","poolbytearray","poolcolorarray","poolintarray","poolrealarray","poolstringarray","poolvector2array","poolvector3array","popup","popupdialog","popupmenu","popuppanel","portal","position2d","position3d","primitivemesh","prismmesh","proceduralsky","progressbar","projectsettings","proximitygroup","proxytexture","quadmesh","quat","randomnumbergenerator","range","raycast","raycast2d","rayshape","rayshape2d","rect2","rectangleshape2d","reference","referencerect","reflectionprobe","regex","regexmatch","remotetransform","remotetransform2d","resource","resourceformatloader","resourceformatsaver","resourceimporter","resourceinteractiveloader","resourceloader","resourcepreloader","resourcesaver","richtexteffect","richtextlabel","rid","rigidbody","rigidbody2d","room","roomgroup","roommanager","rootmotionview","scenestate","scenetree","scenetreetimer","script","scriptcreatedialog","scripteditor","scrollbar","scrollcontainer","segmentshape2d","semaphore","separator","shader","shadermaterial","shape","shape2d","shortcut","skeleton","skeleton2d","skeletonik","skin","skinreference","sky","slider","sliderjoint","softbody","spatial","spatialgizmo","spatialmaterial","spatialvelocitytracker","spheremesh","sphereshape","spinbox","splitcontainer","spotlight","springarm","sprite","sprite3d","spritebase3d","spriteframes","staticbody","staticbody2d","streampeer","streampeerbuffer","streampeergdnative","streampeerssl","streampeertcp","streamtexture","string","stylebox","styleboxempty","styleboxflat","styleboxline","styleboxtexture","surfacetool","tabcontainer","tabs","tcp_server","textedit","textfile","texture","texture3d","texturearray","texturebutton","texturelayered","textureprogress","texturerect","theme","thread","tilemap","tileset","timer","toolbutton","touchscreenbutton","transform","transform2d","translation","translationserver","tree","treeitem","trianglemesh","tween","udpserver","undoredo","upnp","upnpdevice","variant","vboxcontainer","vector2","vector3","vehiclebody","vehiclewheel","videoplayer","videostream","videostreamgdnative","videostreamtheora","videostreamwebm","viewport","viewportcontainer","viewporttexture","visibilityenabler","visibilityenabler2d","visibilitynotifier","visibilitynotifier2d","visualinstance","visualscript","visualscriptbasictypeconstant","visualscriptbuiltinfunc","visualscriptclassconstant","visualscriptcomment","visualscriptcomposearray","visualscriptcondition","visualscriptconstant","visualscriptconstructor","visualscriptcustomnode","visualscriptdeconstruct","visualscripteditor","visualscriptemitsignal","visualscriptenginesingleton","visualscriptexpression","visualscriptfunction","visualscriptfunctioncall","visualscriptfunctionstate","visualscriptglobalconstant","visualscriptindexget","visualscriptindexset","visualscriptinputaction","visualscriptiterator","visualscriptlists","visualscriptlocalvar","visualscriptlocalvarset","visualscriptmathconstant","visualscriptnode","visualscriptoperator","visualscriptpreload","visualscriptpropertyget","visualscriptpropertyset","visualscriptresourcepath","visualscriptreturn","visualscriptscenenode","visualscriptscenetree","visualscriptselect","visualscriptself","visualscriptsequence","visualscriptsubcall","visualscriptswitch","visualscripttypecast","visualscriptvariableget","visualscriptvariableset","visualscriptwhile","visualscriptyield","visualscriptyieldsignal","visualserver","visualshader","visualshadernode","visualshadernodebooleanconstant","visualshadernodebooleanuniform","visualshadernodecolorconstant","visualshadernodecolorfunc","visualshadernodecolorop","visualshadernodecoloruniform","visualshadernodecompare","visualshadernodecubemap","visualshadernodecubemapuniform","visualshadernodecustom","visualshadernodedeterminant","visualshadernodedotproduct","visualshadernodeexpression","visualshadernodefaceforward","visualshadernodefresnel","visualshadernodeglobalexpression","visualshadernodegroupbase","visualshadernodeif","visualshadernodeinput","visualshadernodeis","visualshadernodeouterproduct","visualshadernodeoutput","visualshadernodescalarclamp","visualshadernodescalarconstant","visualshadernodescalarderivativefunc","visualshadernodescalarfunc","visualshadernodescalarinterp","visualshadernodescalarop","visualshadernodescalarsmoothstep","visualshadernodescalarswitch","visualshadernodescalaruniform","visualshadernodeswitch","visualshadernodetexture","visualshadernodetextureuniform","visualshadernodetextureuniformtriplanar","visualshadernodetransformcompose","visualshadernodetransformconstant","visualshadernodetransformdecompose","visualshadernodetransformfunc","visualshadernodetransformmult","visualshadernodetransformuniform","visualshadernodetransformvecmult","visualshadernodeuniform","visualshadernodeuniformref","visualshadernodevec3constant","visualshadernodevec3uniform","visualshadernodevectorclamp","visualshadernodevectorcompose","visualshadernodevectordecompose","visualshadernodevectorderivativefunc","visualshadernodevectordistance","visualshadernodevectorfunc","visualshadernodevectorinterp","visualshadernodevectorlen","visualshadernodevectorop","visualshadernodevectorrefract","visualshadernodevectorscalarmix","visualshadernodevectorscalarsmoothstep","visualshadernodevectorscalarstep","visualshadernodevectorsmoothstep","vscrollbar","vseparator","vslider","vsplitcontainer","weakref","webrtcdatachannel","webrtcdatachannelgdnative","webrtcmultiplayer","webrtcpeerconnection","webrtcpeerconnectiongdnative","websocketclient","websocketmultiplayerpeer","websocketpeer","websocketserver","webxrinterface","windowdialog","world","world2d","worldenvironment","x509certificate","xmlparser","ysort"
]

@dataclass
class Metadata:
    """Container for metadata for Elements"""

    tags: List[str]
    category: str


def extract_metadata(description: str) -> Tuple[str, Metadata, bool]:
    """Finds metadata keys in the provided description and returns the description
without the corresponding lines, as well as the metadata. In the source text,
Metadata should be of the form key: value, e.g. @category - Category Name
The 3rd return value is whether @hidden is present
    """
    tags: List[str] = []
    category: str = ""
    hidden: bool = False

    lines: List[str] = description.split("\n")
    description_trimmed: List[str] = []

    pattern_tags = build_re_pattern("tags")
    pattern_category = build_re_pattern("category")
    pattern_hidden = build_re_pattern("hidden")

    for _, line in enumerate(lines):
        line_stripped: str = line.strip()

        match_tags = re.match(pattern_tags, line_stripped)
        match_category = re.match(pattern_category, line_stripped)
        match_hidden = re.match(pattern_hidden, line_stripped)
        if match_tags:
            tags = match_tags.group(1).split(",")
            tags = list(map(lambda t: t.strip(), tags))
        elif match_category:
            category = match_category.group(1)
        elif match_hidden:
            hidden = True
        else:
            description_trimmed.append(re.sub('^ ', '', line).rstrip())

    metadata: Metadata = Metadata(tags, category)
    return "\n".join(description_trimmed), metadata, hidden


class FunctionTypes(Enum):
    METHOD = 1
    VIRTUAL = 2
    STATIC = 3


@dataclass
class ProjectInfo:
    name: str
    description: str
    version: str

    @staticmethod
    def from_dict(data: dict):
        return ProjectInfo(data["name"], data["description"], data["version"])


@dataclass
class Element:
    """Base type for all main GDScript symbol types. Contains properties common to
Signals, Functions, Member variables, etc."""

    signature: str
    name: str
    description: str

    def __post_init__(self):
        _description, self.metadata, self.hidden = extract_metadata(self.description)
        self.description = _description.strip("\n")

    def get_heading_as_string(self) -> str:
        """Returns an empty string. Virtual method to get a list of strings representing
the element as a markdown heading."""
        return self.name

    def get_unique_attributes_as_markdown(self) -> List[str]:
        """Returns an empty list. Virtual method to get a list of strings describing the
unique attributes of this element."""
        return []

    @staticmethod
    def from_dict(data: dict) -> "Element":
        return Element(data["signature"], data["name"], data["description"])


@dataclass
class Signal(Element):
    arguments: List[str]

    @staticmethod
    def from_dict(data: dict) -> "Signal":
        return Signal(
            data["signature"], data["name"], data["description"], data["arguments"],
        )


@dataclass
class Argument:
    """Container for function arguments."""

    name: str
    type: str


@dataclass
class Function(Element):
    kind: FunctionTypes
    return_type: str
    arguments: List[Argument]
    rpc_mode: int

    def __post_init__(self):
        super().__post_init__()
        self.signature = self.signature.replace("-> null", "-> void", 1)
        self.return_type = self.return_type.replace("null", "void", 1)
        
        self.returns = ""
        self.params = []

        lines = self.description.split("\n")
        pattern_params = "^@param ([^\s]+) - (.+)"
        pattern_returns = "^@returns (.+)"
        description_trimmed: List[str] = []

        for _, line in enumerate(lines):
            line_stripped: str = line.strip()

            match_params = re.match(pattern_params, line_stripped)
            match_returns = re.match(pattern_returns, line_stripped)
            if match_params:
                self.params.append((match_params.group(1), match_params.group(2)))
            elif match_returns:
                self.returns = match_returns.group(1)
            else:
                description_trimmed.append(re.sub('^ ', '', line).rstrip())
        
        self.description = "\n".join(description_trimmed)

    def summarize(self) -> List[str]:
        return [self.return_type, self.signature]
    
    def get_unique_attributes_as_markdown(self) -> List[str]:
        unique_attributes: List[str] = []
        if len(self.params) > 0:
            params_list = []
            for param in self.params:
                params_list.append(make_bold(param[0]) + ": " + param[1])
            unique_attributes.append(make_bold("Parameters") + "\n")
            unique_attributes.append("\n".join(["  - " + param for param in params_list]))
        
        if len(self.returns) > 0 and len(self.returns) > 0:
            unique_attributes.append("\n")
        
        if len(self.returns) > 0:
            unique_attributes.append(make_bold("Returns:") + " " + self.returns)

        if len(unique_attributes) > 0:
            unique_attributes.append("")
        return unique_attributes

    def get_heading_as_string(self) -> str:
        """Returns an empty list. Virtual method to get a list of strings representing
the element as a markdown heading."""
        heading: str = self.name
        if self.kind == FunctionTypes.VIRTUAL:
            heading += " " + surround_with_html("(virtual)", "small")
        if self.kind == FunctionTypes.STATIC:
            heading += " " + surround_with_html("(static)", "small")
        return heading

    @staticmethod
    def from_dict(data: dict) -> "Function":
        kind: FunctionTypes = FunctionTypes.METHOD
        if data["is_static"]:
            kind = FunctionTypes.STATIC
        elif data["is_virtual"]:
            kind = FunctionTypes.VIRTUAL

        return Function(
            data["signature"],
            data["name"],
            data["description"],
            kind,
            data["return_type"],
            Function._get_arguments(data["arguments"]),
            data["rpc_mode"] if "rpc_mode" in data else 0,
        )

    @staticmethod
    def _get_arguments(data: List[dict]) -> List[Argument]:
        return [Argument(entry["name"], entry["type"],) for entry in data]


@dataclass
class Enumeration(Element):
    """Represents an enum with its constants"""

    values: dict

    @staticmethod
    def from_dict(data: dict) -> "Enumeration":
        return Enumeration(
            data["signature"], data["name"], data["description"], data["value"],
        )


@dataclass
class Member(Element):
    """Represents a property or member variable"""

    type: str
    default_value: str
    is_exported: bool
    setter: str
    getter: str

    def summarize(self) -> List[str]:
        return [self.type, self.name]

    def get_unique_attributes_as_markdown(self) -> List[str]:
        setget: List[str] = []
        if self.setter and not self.setter.startswith("_"):
            setget.append(make_bold("Setter") + ": " + make_code_inline(self.setter))
        if self.getter and not self.getter.startswith("_"):
            setget.append(make_bold("Getter") + ": " + make_code_inline(self.getter))
        setget = make_list(setget)
        if len(setget) > 0:
            setget.append("")
        return setget

    @staticmethod
    def from_dict(data: dict) -> "Member":
        return Member(
            data["signature"],
            data["name"],
            data["description"],
            data["data_type"],
            data["default_value"],
            data["export"],
            data["setter"],
            data["getter"],
        )


@dataclass
class Constant(Element):
    """Represents a constant"""

    type: str
    default_value: str

    def summarize(self) -> List[str]:
        return [self.type, self.name]

    @staticmethod
    def from_dict(data: dict) -> "Constant":
        return Constant(
            data["signature"],
            data["name"],
            data["description"],
            data["data_type"],
            data["value"],
        )


@dataclass
class GDScriptClass:
    name: str
    extends: str
    description: str
    path: str
    functions: List[Function]
    members: List[Member]
    constants: List[Constant]
    signals: List[Signal]
    enums: List[Enumeration]
    sub_classes: List["GDScriptClass"]
    category: str
    def __post_init__(self):
        description, self.metadata, self.hidden = extract_metadata(self.description)
        if (self.metadata.category):
            self.category = self.metadata.category.title() if isinstance(self.metadata.category, str) else "Uncategorized"
        self.description = description.strip("\n ")
        elements = self.functions + self.members + self.signals + self.enums
        self.symbols = {element.name for element in elements}

    @staticmethod
    def from_dict(data: dict):
        # the extends_class field is a list in json even though it only has one
        # class.
        extends: str = data["extends_class"][0] if data["extends_class"] else ""

        enumerations = []

        for entry in data["constants"]:
            if entry["data_type"] == "Dictionary" and all(isinstance(v, int) for v in entry["value"].values()) and not entry["name"].startswith("_"):
                enumeration = Enumeration.from_dict(entry)
                if enumeration.hidden:
                    continue
                enumerations.append(enumeration)
        return GDScriptClass(
            data["name"],
            extends,
            data["description"],
            data["path"],
            _get_functions(data["methods"])
            + _get_functions(data["static_functions"], is_static=True),
            _get_members(data["members"]),
            _get_constants(data["constants"]),
            _get_signals(data["signals"]),
            enumerations,
            [GDScriptClass.from_dict(data) for data in data["sub_classes"]],
            "Uncategorized",
        )

    def get_extends_tree(self, classes: "GDScriptClasses") -> List[str]:
        """Returns the list of ancestors for this class, starting from self.extends.

        Arguments:

        - classes: a GDScriptClasses list of GDScriptClass this object is part
          of.

        """
        extends: str = self.extends
        extends_tree: List[str] = []
        while extends != "":
            extends_tree.append(extends)
            extends = next((cls.extends for cls in classes if cls.name == extends), "")
        return extends_tree


class GDScriptClasses(list):
    """Container for a list of GDScriptClass objects

    Provides methods for filtering and grouping GDScript classes"""

    def __init__(self, *args):
        super(GDScriptClasses, self).__init__(args[0])
        self.class_index = {
            gdscript_class.name: gdscript_class.symbols for gdscript_class in self
        }

    def _get_grouped_by(self, attribute: str) -> List[List[GDScriptClass]]:
        if not self or attribute not in self[0].__dict__:
            return []

        groups = []
        get_attribute = operator.attrgetter(attribute)
        data = sorted(self, key=get_attribute)
        for key, group in itertools.groupby(data, get_attribute):
            groups.append(list(group))
        return groups

    def get_grouped_by_category(self) -> List[List[GDScriptClass]]:
        """Returns a list of lists of GDScriptClass objects, grouped by their `category`
attribute"""
        return self._get_grouped_by("category")

    @staticmethod
    def from_dict_list(data: List[dict]):
        ret_gdscript_classes = []
        for entry in data:
            if "name" not in entry:
                continue
            
            ret_gdscript_class = GDScriptClass.from_dict(entry)
            if ret_gdscript_class.hidden:
                continue
            
            ret_gdscript_classes.append(ret_gdscript_class)

        return GDScriptClasses(ret_gdscript_classes)


def _get_signals(data: List[dict]) -> List[Signal]:
    return list(filter(lambda signal: not signal.hidden, [Signal.from_dict(entry) for entry in data]))


def _get_functions(data: List[dict], is_static: bool = False) -> List[Function]:
    """Returns a list of valid functions to put in the class reference. Skips
built-in virtual callbacks, except for constructor functions marked for
inclusion, and private methods."""
    functions: List[Function] = []
    for entry in data:
        name: str = entry["name"]
        if name in BUILTIN_VIRTUAL_CALLBACKS:
            continue
        if name == TYPE_CONSTRUCTOR and not entry["arguments"]:
            continue

        _, metadata, is_hidden = extract_metadata(entry["description"])

        is_virtual: bool = "virtual" in metadata.tags and not is_static
        is_private: bool = name.startswith("_") and not is_virtual and name != TYPE_CONSTRUCTOR
        if is_private or is_hidden:
            continue

        function_data: dict = entry
        function_data["is_virtual"] = is_virtual
        function_data["is_static"] = is_static
        function = Function.from_dict(function_data)
        if function.hidden:
            continue
        functions.append(function)
    return functions


def _get_members(data: List[dict]) -> List[Member]:
    return list(filter(lambda member: not member.hidden, [
        Member.from_dict(entry) for entry in data if not entry["name"].startswith("_")
    ]))


def _get_constants(constants_data: List[dict]) -> List[Constant]:
    """Filters and distinguishes constants from enums."""

    def is_not_enum(constant):
        """Returns `True` if the constant's source data doesn't correspond to an enum.
        That is, if it's not a dictionary with only a list of named integers."""
        is_enum = constant["data_type"] == "Dictionary"
        is_enum = is_enum and all(
            isinstance(value, int) for value in constant["value"].values()
        )
        return not is_enum

    constants = filter(lambda c: not c["name"].startswith("_"), constants_data)
    constants = filter(is_not_enum, constants)
    constants = sorted(constants, key=itemgetter("name"))
    constants = list(map(lambda c: Constant.from_dict(c), constants))
    return filter(lambda c: not c.hidden, constants)
