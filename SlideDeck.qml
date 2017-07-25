import QtQuick 2.8
import QtQuick.Particles 2.0
import Qt.labs.presentation 1.0

Presentation {
    id: presentation

    property real fontScale: 0.7

    Image {
        anchors.fill: parent
        source: "background.png"
    }

    FontLoader {
        id: titilium
        source: "TitilliumWeb-Regular.ttf"
    }

    FontLoader {
        id: titiliumLight
        source: "TitilliumWeb-Light.ttf"
    }

    fontFamily: titilium.name
    codeFontFamily: titiliumLight.name

    SlideCounter {}
    Clock {}

    Slide {
        centeredText: "<h1>Qt WebGL Streaming</h1><br>" +
                      "by Jesús Fernández (<a href=\"mailto:jesus.fernandez@qt.io\">jesus.fernandez@qt.io</a>)"
    }

    Slide {
        title: "Who am I?"
        fontScale: parent.fontScale

        content: [
            "Panda Security",
            "Hewlett-Packard",
            "Gameloft",
            "The Qt Company",
            " QtNetworkAuth Mantainer",
            " QtWebGLStreaming Plugin Mantainer"
        ]
    }

    Slide {
        title: "What's WebGL?"

        Image {
            source: "https://nickdesaulniers.github.io/RawWebGL/history.jpg"
            anchors.centerIn: parent
        }
    }

    Slide {
        title: "What's Qt WebGL Streaming?"

        centeredText: "Enables streaming of Qt applications using OpenGLES2"
    }

    Slide {
        title: "Use cases"

        content: [
            "Remote application access",
            "Publish applications",
            "Remote control of devices",
            "Presentations"
        ]
    }

    Slide {
        title: "How was it implemented?"

        content: [
            "Qt Platform Abstraction (QPA) Plugin",
            "Minimal WebServer",
            "QtWebSocketServer",
            "JavaScript",
            "WebGL"
        ]
    }

    Slide {
        title: "What's QPA?"
        content: [
            "Set of interfaces to customize the behaviour of the Qt applications",
            "It's a way to support different OS without changing Qt code",
            "Determines how to open windows",
            "It resolves the OpenGL function pointers"
        ]
    }

    Slide {
        title: "The WebServer"
        content: [
            "It uses Qt",
            "It sends the Javascript and edits it to set and some custom routes",
            "It's a temporary solution"
        ]
    }

    Slide {
        title: "QtWebsocketServer"
        content: [
            "Connects the application and the browser",
            "Sends the GLES2 calls in a binary format",
            "Sends the user interaction to the application",
            "Sends reponses from the WebGL calls if needed"
        ]
    }

    Slide {
        title: "Javascript"
        content: [
            "Receives GLES2 calls in binary format",
            "Converts this binary format into WebGL",
            "Uses event handlers to send user interaction"
        ]
    }

    Slide {
        title: "WebGL"

        Image {
            source: "Cube.png"
            fillMode: Image.PreserveAspectFit
            width: parent.width
            height: parent.height
            anchors.centerIn: parent
        }
    }

    Slide {
        centeredText: "OK, where are the particles?"
    }

    Slide {
        title: "Here"

        ParticleSystem {
            clip: true
            id: root
//            width: 320
//            height: 480
            anchors.fill: parent
            Rectangle {
                z: -1
                anchors.fill: parent
                color: "black"
                Text {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 14
                    color: "white"
                    text: "It's all in the fragment shader."
                }
            }

            Emitter {
                emitRate: 400
                lifeSpan: 8000
                size: 24
                sizeVariation: 16
                velocity: PointDirection {x: root.width/10; y: root.height/10;}
                acceleration: PointDirection {x: -root.width/40; y: -root.height/40; xVariation: -root.width/20; yVariation: -root.width/20}
            }

            CustomParticle {
                vertexShader:"
                    uniform lowp float qt_Opacity;
                    varying lowp float fFade;
                    varying highp vec2 fPos;

                    void main() {
                        qt_TexCoord0 = qt_ParticleTex;
                        highp float size = qt_ParticleData.z;
                        highp float endSize = qt_ParticleData.w;

                        highp float t = (qt_Timestamp - qt_ParticleData.x) / qt_ParticleData.y;

                        highp float currentSize = mix(size, endSize, t * t);

                        if (t < 0. || t > 1.)
                        currentSize = 0.;

                        highp vec2 pos = qt_ParticlePos
                        - currentSize / 2. + currentSize * qt_ParticleTex          // adjust size
                        + qt_ParticleVec.xy * t * qt_ParticleData.y         // apply velocity vector..
                        + 0.5 * qt_ParticleVec.zw * pow(t * qt_ParticleData.y, 2.);

                        gl_Position = qt_Matrix * vec4(pos.x, pos.y, 0, 1);

                        highp float fadeIn = min(t * 20., 1.);
                        highp float fadeOut = 1. - max(0., min((t - 0.75) * 4., 1.));

                        fFade = fadeIn * fadeOut * qt_Opacity;
                        fPos = vec2(pos.x/320., pos.y/480.);
                    }
                "
                //! [0]
                fragmentShader: "
                    varying highp vec2 fPos;
                    varying lowp float fFade;
                    varying highp vec2 qt_TexCoord0;
                    void main() {//*2 because this generates dark colors mostly
                        highp vec2 circlePos = qt_TexCoord0*2.0 - vec2(1.0,1.0);
                        highp float dist = length(circlePos);
                        highp float circleFactor = max(min(1.0 - dist, 1.0), 0.0);
                        gl_FragColor = vec4(fPos.x*2.0 - fPos.y, fPos.y*2.0 - fPos.x, fPos.x*fPos.y*2.0, 0.0) * circleFactor * fFade;
                    }"
                //! [0]

            }
        }
    }

    Slide {
        title: "What's supported?"
        content: [
            "Qt Quick",
            "Qt OpenGL",
            "Single user",
            " What?",
            " Why? I want to create multiuser web applications! >:-|"
        ]
    }

    Slide {
        title: "Why single user?"
        content: [
            "Problem with user input",
            "Problem with querying the GPU",
            "We can improve security"
        ]
    }

    Slide {
        title: "... People leaving the room ..."

        content: [
            "We are working in decoupling the HTTP Server from the plugin",
            "A dedicated HTTP Server application will be provided",
            " Instead of running all the users in the same process a new process will be spawned " +
                "per user",
            " The new process will inherit the web socket created by the browser"
        ]
    }

    CodeSlide {
        title: "Show me the code!"
        code: "        gl._attachShader = gl.attachShader;
        gl.attachShader = function(program, shader) {
            var d = contextData[currentContext];
            gl._attachShader(d.programMap[program], d.shaderMap[shader].shader);
        };

        gl._bindAttribLocation = gl.bindAttribLocation;
        gl.bindAttribLocation = function(program, index, name) {
            var d = contextData[currentContext];
            gl._bindAttribLocation(d.programMap[program], index, name);
        };

        gl._bindBuffer = gl.bindBuffer;
        gl.bindBuffer = function(target, buffer) {
            var d = contextData[currentContext];
            gl._bindBuffer(target, buffer ? d.bufferMap[buffer] : null);
        };

        gl._bindFramebuffer = gl.bindFramebuffer;
        gl.bindFramebuffer = function(target, framebuffer) {
            var d = contextData[currentContext];
            gl._bindFramebuffer(target, framebuffer ? d.framebufferMap[framebuffer] : null);
        };

        gl._bindRenderbuffer = gl.bindRenderbuffer;
        gl.bindRenderbuffer = function(target, renderbuffer) {
            var d = contextData[currentContext];
            gl._bindRenderbuffer(target, renderbuffer ? d.renderbufferMap[renderbuffer] : null);
            d.boundRenderbuffer = renderbuffer;
        };

        gl._bindTexture = gl.bindTexture;
        gl.bindTexture = function(target, texture) {
            gl._bindTexture(target, texture ? mapTexture(currentContext, texture) : null);
        };

        gl._bufferData = gl.bufferData;
        gl.bufferData = function(target, usage, size, data) {
            gl._bufferData(target, data.length === 0 ? size : data, usage);
        };

        gl._clearColor = gl.clearColor;
        gl.clearColor = function (red, green, blue, alpha) {
            gl._clearColor(red, green, blue, alpha);
        }

        gl.clearDepthf = function(depth) {
            gl.clearDepth(depth);
        };

        gl._compileShader = gl.compileShader;
        gl.compileShader = function(remoteShader) {
            var d = contextData[currentContext];
            gl._compileShader(d.shaderMap[remoteShader].shader);
        };

        gl._createProgram = gl.createProgram;
        gl.createProgram = function() {
            var d = contextData[currentContext];
            var remoteProgram = d.nextProgramId++;
            var localProgram = gl._createProgram();
            d.programMap[remoteProgram] = localProgram;
            return remoteProgram;
        };

        gl._createShader = gl.createShader;
        gl.createShader = function(type) {
            var d = contextData[currentContext];
            var remoteShader = d.nextShaderId++;
            var localShader = gl._createShader(type);
            d.shaderMap[remoteShader] = { };
            d.shaderMap[remoteShader].shader = localShader;
            d.shaderMap[remoteShader].source = \"\";
            return remoteShader;
        };"
    }

    Slide {
        AnimatedImage {
            source: "http://gclipart.com/wp-content/uploads/2017/03/Question-mark-clipart-transparent-background.gif"
            onStatusChanged: playing = (status == AnimatedImage.Ready)
            anchors.centerIn: parent
        }
    }
}
