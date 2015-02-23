* Chapter Background 
** Title Introduction
Body {
Chip design disciplines could not have kept up with miniaturization generations if it 
wasn't for the imrovements in design automation software. The human effort that characterized early generations of integrated-circuits can not be scaled up with the number of transistors
per chip and the increasing complexity introduced by physical limitations of shrinking geometry. This progress of integrated-circuit technology together with tool algorithms and computation 
power has been more or less steady in time, but not equal between design domains. Digital design, especially in the ASIC segment, progressed much faster than analog design. The industry 
adapted to the analog lag by assigning minimal functionality to the analog parts of the system and keeping a relative high ratio of designers per transistor on the analog modules. Where 
possible, analog functionality was completely outsourced to an external IP provider or even exiled to an external circuit that was manufactured using older but proven technology.
The reasons for the automation-lag between the digital and analog domains start with the complexity of problems introduced by the two. Digital design compartmentalize the analog aspects 
of the circuits functionality and solves them separately. Shortcut circuit verification techniques, such as STA and physical synthesis rules, simplify and modularize design efforts. 
In the analog domain, there are very few opportunities to reduce components to black-boxes, much less to separate the effort to decoupled sub-domains. Autoamtion meant different things 
for the two domains. Digital design received more attention and therefore more types of tools. The tool set was divided to two classes: design and sign-off. The former class is fast but 
inaccurate and expected to be used many times during the design cycle. The latter class of tools attempts to be as close as possible to chip performance,on the paranoid side. It trades 
run time for this accuracy and therefore reserved to final stges of the cycle. In the analog domain there is no such separation. All tools can be classified as sign-off. The biggest gap 
between the two domains is in the lack of synthesis tools for analog design. The synthesizer is by and large a human engineer, who relies on simulations to navigate her trial and error 
process. So far, analog design automation focused on two aspects that showed promising marketability: simulation and flow-management. Actual synthesis received mostly academic attention, 
which sometime translated to temporary industry success, but more often failed or was ignored completely.
An investigation of the reasons as to why analog design automation failed to reach a significant breakthrough since the advent of SPICE in the early 1970's can be simplified to 
the return on investment comparison between proposed tools cost (license+hardware×run-time) and human hours. However, the reasons for the industry's inacceptance of analog design tools
 are many and some are outside the scope of pure technical analysis. When we analyze a product's desireablity,
we need to consider the issue of product-quality. According to the UN's Industrial Development Organization (UNIDO) product quality can be defined as 
"its ability to fulfil the customer's needs and expectations" [Ref: http://www.unido.org/fileadmin/media/documents/pdf/tcb_product_quality.pdf:11]. 
Unfortunately for the analog domain, both needs and expectations were derived from automation acheivements on the digital domain. Countless promises of analog synthesis and static analog analysis 
were broken on the most important issue: customers' expectations. 
In the past decade, a new development in the software industry presents an opportunity to a new class of design automation tools: online software suites (a.k.a. web-apps), which make use
of a shared computing resource, commonly refered to as "the cloud". This segment of software products is inherently different from customer-premise software, even if declared to perform the same 
function. The differences between user-equipment and cloud software is summarized in the following table:
}
Table 
