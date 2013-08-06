import re
import glob
import os

MODULE_GLOBS = ["../jpconditionparser.lua","../jprotations.lua","../modules/*.lua"]
ADVANCED_GLOBS = ["../jplogging.lua","../jpparse.lua","../jpevents.lua"]
ROTATION_GLOBS = ["../Rotations/*.lua"]
TODO_GLOBS = ["../*.lua","../*/*.lua"]
TALENT_CALCULATOR_URL = "http://eu.battle.net/wow/en/tool/talent-calculator"

BB_CODE = {
"[b]": "<b>",
"[/b]": "</b>",
"[p]": "<p>",
"[/p]": "</p>",
"[i]": "<i>",
"[/i]": "</i>",
"[tt]": "<div class=\"tt\">",
"[/tt]": "</div>",
"[code]": "<code>",
"[/code]": "</code>",
"[sup]": "<sup>",
"[/sup]": "</sup>",
"[sub]": "<sub>",
"[/sub]": "</sub>",
"[del]": "<del>",
"[/del]": "</del>",
"[br]": "<br />",
"[*]": "&bull;",
"[--]": "&nbsp;&nbsp;&nbsp;&nbsp;",
}

CLASS_SPECS = {
"death knight" : ["blood","frost","unholy"],
"druid" : ["balance","feral","guardian","restoration"],
"hunter" : ["beastmastery","marksmanship","survival"],
"mage" : ["arcane","fire","frost"],
"monk" : ["brewmaster","mistweaver","windwalker"],
"paladin" : ["holy","protection","retribution"],
"priest" : ["discipline","holy","shadow"],
"rogue" : ["assassination","combat","subtlety"],
"shaman" : ["elemental","enhancement","restoration"],
"warlock" : ["affliction","demonology","destruction"],
"warrior" : ["arms","fury","protection"],
}

class Log():
    def __init__(self, logLevel):
        self.logLevel = logLevel
    def debug(self, msg, *params):
        if self.logLevel <= 1:
            print "DEBUG: %s" % (msg % (params))
    def info(self, msg, *params):
        if self.logLevel <= 2:
            print " INFO: %s" % (msg % (params))
    def warn(self, msg, *params):
        if self.logLevel <= 3:
            print " WARN: %s" % (msg % (params))
    def error(self, msg, *params):
        if self.logLevel <= 4:
            print "ERROR: %s" % (msg % (params))
LOG = Log(2)

class DocElement():
    def __init__(self,content):
        self.content = content

    def readTags(self):
        return self._readTags(self.content)
        
    def _readTags(self, text):
        currentTag = None
        tags = []
        words = []
        for word in re.findall("[^\s]+", text):
            if len(word) > 1 and word[0] == '@':
                tags.append((currentTag, words))
                currentTag = word
                words = []
            else:
                words.append(word)
        tags.append((currentTag, words))
        return tags
    
    def _bbCodeWord(self, word):
        for bb,html in BB_CODE.iteritems():
            if word == bb:
                return html
            word = word.replace(bb,html)
        if word.startswith("#ref:"):
            id = word[5:]
            return "<a href=\"#%s\" class=\"ref\">%s</a>" % (id,id)
        # FIXME:this one's ugly...use regex!
        if word.startswith("(#ref:"):
            id = word[6:]
            if id[-1] == ")":
                return "(<a href=\"#%s\" class=\"ref\">%s</a>)" % (id[:-1],id[:-1])
            if id[-2] == ")":
                return "(<a href=\"#%s\" class=\"ref\">%s</a>%s" % (id[:-2],id[:-2],id[-2:])
            else:
                return "(<a href=\"#%s\" class=\"ref\">%s</a>" % (id,id)
        return word
    
    def _bbCode(self,wordList):
        return map(self._bbCodeWord, wordList)

    def getTagData(self, tagName, tagList):
        for tag,words in tagList:
            if tag == tagName:
                tagData = " ".join(self._bbCode(words))
                LOG.debug("Tag '%s': %s",tag, tagData)
                return tagData
        return None

    def getParamTagData(self, tagList):
        tagName = "@param"
        list = []
        for tag,words in tagList:
            if tag == tagName:
                param = words[0]
                description = " ".join(self._bbCode(words[1:]))
                LOG.debug("Param '%s': %s",param, description)
                list.append((param,description))
        return list

    def isValid(self):
        return False

    def genDoc(self):
        return ""

class DocFile(DocElement):
    def __init__(self, filename):
        DocElement.__init__(self,open(filename, "r").read())
        offset = 0
        self.sections = []
        while offset >= 0:
            offset = self.content.find("--[[[", offset)
            if offset >= 0:
                end = self.content.find("]]--", offset)
                if end == -1:
                    LOG.warn("Unmatched --[[[ in file '%s'", filename)
                    break
                LOG.debug("Found Document section in '%s': %d - %d", filename, offset, end)
                self.sections.append((offset+5, end))
                offset = offset + 1

    def readTags(self, start, end):
        return self._readTags(self.content[start:end])

class Module(DocFile):    
    def __init__(self, filename):
        DocFile.__init__(self, filename)
        self.functions = []
        if len(self.sections) < 1:
            LOG.warn("Module '%s' doesn't have a Module comment!", filename)
        else:
            # Module Doc
            start,end = self.sections[0]
            tagList = self.readTags(start,end)
            self.name = self.getTagData("@module",tagList)
            self.description = self.getTagData("@description",tagList)
            # Module Functions
            for start,end in self.sections[1:]:
                LOG.debug("Function %d-%d in '%s':", start,end,filename)
                self.functions.append(ModuleFunction(self.content[start:end]))
            # Check functions
            functionsInFile = getFunctions(filename)
            undocumentedFunctionsInFile = getFunctions(filename)
            functionCountInFile = len(functionsInFile)
            functionCountCommented = 0
            for mf in self.functions:
                functionCountCommented = functionCountCommented + 1 # also count invalid!
                if mf.isValid():
                    if not mf.name in functionsInFile:
                        LOG.warn("Module '%s' documents global function '%s', but doesn't exist in the file!", filename, mf.name)
                    else:
                        if mf.name in undocumentedFunctionsInFile: 
                            undocumentedFunctionsInFile.remove(mf.name)
                        else:
                            LOG.warn("Module '%s' documents global function '%s', multiple times!", filename, mf.name)
            if functionCountInFile > functionCountCommented:
                LOG.warn("Module '%s' has %d global functions, but only %d are commented! Undocumented: %s",filename, functionCountInFile, functionCountCommented, ", ".join(undocumentedFunctionsInFile))
            if functionCountInFile < functionCountCommented:
                LOG.warn("Module '%s' only has %d global functions, but %d are commented!",filename, functionCountInFile, functionCountCommented)

    def isValid(self):
        return hasattr(self, "name") and self.name != None

    def genDoc(self):
        msg = "<div class=\"module\">\n"
        msg = msg + "<div class=\"module-name\">%s</div>\n" % self.name
        msg = msg + "<div class=\"module-description\">%s</div>\n" % self.description
        for function in self.functions:
            if function.isValid():
                msg = msg + function.genDoc()
        msg = msg + "</div>\n"
        return msg

class ModuleFunction(DocElement):
    def __init__(self,content):
        DocElement.__init__(self, content)
        self.tagList = self.readTags()
        self.name = self.getTagData("@function",self.tagList)
        self.description = self.getTagData("@description",self.tagList)
        self.params = self.getParamTagData(self.tagList)
        self.returns = self.getTagData("@returns",self.tagList)
        self.deprecated = self.getTagData("@deprecated",self.tagList)

    def getFunctionName(self):
        paramText = ""
        for param,description in self.params:
            paramText = paramText + ", " + param
        return "function %s(%s)" % (self.name, paramText[2:])

    def genDoc(self):
        #msg = "<div class=\"module-function\" id=\"%s\"><a name=\"%s\" />\n" % (self.name,self.name)
        msg = "<div class=\"module-function\" id=\"%s\">\n" % (self.name)
        msg = msg + "<div class=\"module-function-name\">%s</div>\n" % self.getFunctionName()
        description = self.description
        if self.deprecated != None:
            description = "<i>This function is DEPRECATED! %s</i><br /><br />%s" % (self.deprecated, description) 
        msg = msg + "<div class=\"module-function-description\">%s</div>\n" % description
        if len(self.params) > 0:
            msg = msg + "<div class=\"module-function-section\">Parameters:</div>\n"
            msg = msg + "<ul class=\"module-function-parameters\">\n"
            for param,description in self.params:
                msg = msg + "  <li class=\"module-function-parameter\"><b>%s:</b> %s</li>\n" % (param,description)
            msg = msg + "</ul>\n"
        if self.returns:
            msg = msg + "<div class=\"module-function-section\">Returns:</div>\n"
            msg = msg + "<div class=\"module-function-returns\">%s</div>\n" % self.returns
        msg = msg + "</div>\n"
        return msg
        
    def isValid(self):
        return self.name != None

class RotationFile(DocFile):    
    def __init__(self, filename):
        DocFile.__init__(self, filename)
        self.rotations = []
        for start,end in self.sections:
            LOG.debug("Rotation %d-%d in '%s':", start,end,filename)
            self.rotations.append(RotationComment(self.content[start:end]))
    
    def genDoc(self,className,specName):
        doc = ""
        for rotation in self.rotations:
            if rotation.className == className and rotation.specName == specName:
                doc = doc + rotation.genDoc()
        return doc

class RotationComment(DocElement):
    def __init__(self,content):
        DocElement.__init__(self, content)
        self.tagList = self.readTags()
        self.name = self.getTagData("@rotation",self.tagList)
        self.className = self.getTagData("@class",self.tagList).lower()
        self.specName = self.getTagData("@spec",self.tagList).lower()
        self.talents = self.getTagData("@talents",self.tagList)
        self.author = self.getTagData("@author",self.tagList)
        if not self.author:
            self.author = "Unknown"
        self.description = self.getTagData("@description",self.tagList)
        self.deprecated = self.getTagData("@deprecated",self.tagList)

    def isValid(self):
        return self.name != None
    
    def genDoc(self):
        msg = "<div class=\"rotation\">\n"
        talentUrl = ""
        if self.talents != None:
            talentUrl = " (<a href=\"%s#%s\" class=\"talent-url\">Talents</a>)" % (TALENT_CALCULATOR_URL, self.talents)
        msg = msg + "<div class=\"rotation-name\">'%s' <i>by %s</i>%s</div>\n" % (self.name,self.author,talentUrl)
        description = self.description
        if self.deprecated != None:
            description = "<i>This Rotation is DEPRECATED! %s</i><br /><br />%s" % (self.deprecated, description) 
        msg = msg + "<div class=\"rotation-description\">%s</div>\n" % description
        msg = msg + "</div>\n"
        return msg


def getFunctions(filename):
    functions = []
    inComment = False
    for line in open(filename,"r").readlines():
        posStart = line.find("--[[")
        posEnd = line.find("]]")
        if posStart >= 0 and (posEnd <0 or posEnd < posStart):
            inComment = True
        elif posEnd >= 0:
            inComment = False
        if not inComment and line.startswith("function"):
            res = re.search("(?<=function)[^(]*",line)
            if res:
                fn = res.group(0).strip()
                LOG.debug("Found Function in '%s': %s", filename,fn)
                functions.append(fn)
    return functions

def getFileTodoDoc(filename):
    todos = []
    for line in open(filename,"r").readlines():
        res = re.search("(?<=JPTODO:).*",line)
        if res:
            todo = res.group(0).strip()
            LOG.info("Found TODO in '%s': %s" % (filename,todo))
            todos.append(todo)
    if len(todos)==0:
        return ""
    msg = "<div class=\"todo\">\n"
    msg = msg + "  <div class=\"todo-file\">%s</div>\n" % os.path.basename(filename)
    msg = msg + "  <ul class=\"todo-list\">\n"
    for todo in todos:
        msg = msg + "<li class=\"todo-item\">%s</li>\n" % (todo)
    msg = msg + "  </ul>\n"
    msg = msg + "</div>\n"
    return msg

def getTodoDoc():
    doc = ""
    for globList in TODO_GLOBS:
        for file in glob.glob(globList):
            doc = doc + getFileTodoDoc(file)
    if doc != "":
        doc = "<div class=\"section\">\n<div class=\"section-title\">ToDo's</div>\n" + doc + "</div>\n"
    return doc

def getRotationDoc():
    rotations = []
    rotationsDoc = ""
    for globList in ROTATION_GLOBS:
        for file in glob.glob(globList):
            rotations.append(RotationFile(file))
    for className, specList in CLASS_SPECS.iteritems():
        className = className.lower()
        classKey = className.replace(" ","_")
        classDoc = ""
        for specName in specList:
            specName = specName.lower()
            specKey = specName.replace(" ","_")
            classSpecKey = classKey + "_" + specKey
            doc = ""
            for rotation in rotations:
                doc = doc + rotation.genDoc(className,specName)
            if doc != "":
                classDoc = classDoc + "<div class=\"rotations-spec\">\n"
                classDoc = classDoc + "  <div class=\"rotation-spec-title %s\">%s</div>\n" % (classSpecKey, specName)
                classDoc = classDoc + doc
                classDoc = classDoc + "</div>\n"
        if classDoc != "":
            rotationsDoc = rotationsDoc + "<div class=\"rotation-class\">\n"
            rotationsDoc = rotationsDoc + "<div class=\"rotation-class-title %s\">%s</div>\n" % (classKey, className)
            rotationsDoc = rotationsDoc + classDoc
            rotationsDoc = rotationsDoc + "</div>\n"
    return rotationsDoc

def genDoc():
    doc = ""
    doc = doc + "<div class=\"section\">\n"
    doc = doc + "<div class=\"section-title\">Modules</div>\n"
    for globList in MODULE_GLOBS:
        for file in glob.glob(globList):
            elem = Module(file)
            if elem.isValid():
                doc = doc + elem.genDoc()
    doc = doc + "</div>\n"
    doc = doc + "<div class=\"section\">\n"
    doc = doc + "<div class=\"section-title\">Advanced Functionality</div>\n"
    for globList in ADVANCED_GLOBS:
        for file in glob.glob(globList):
            elem = Module(file)
            if elem.isValid():
                doc = doc + elem.genDoc()
    doc = doc + "</div>\n"
    doc = doc + "<div class=\"section\">\n"
    doc = doc + "<div class=\"section-title\">Rotations</div>\n"
    doc = doc + getRotationDoc()
    doc = doc + "</div>\n"
    doc = doc + getTodoDoc()
    return doc

if __name__ == "__main__":
    template = open("index.html.in", "r").read()
    template = template % genDoc()
    open("index.html", "w").write(template)
