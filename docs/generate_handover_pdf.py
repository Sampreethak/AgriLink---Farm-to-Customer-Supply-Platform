import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, KeepTogether, HRFlowable, PageBreak
)
from reportlab.pdfgen import canvas

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PDF_PATH = os.path.join(BASE_DIR, "AgriLink_Project_Opportunity_Document.pdf")

# Pure Black & White Palette
BLACK = colors.black
DARK_GRAY = colors.HexColor("#333333")
MID_GRAY = colors.HexColor("#666666")
LIGHT_GRAY = colors.HexColor("#E5E5E5")
VERY_LIGHT_GRAY = colors.HexColor("#F8F8F8")
WHITE = colors.white

class MonochromeNumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("Helvetica", 8)
        self.setFillColor(DARK_GRAY)
        
        # Running Top Header (pages > 1)
        if self._pageNumber > 1:
            self.drawString(54, 752, "AgriLink — Project Overview & Student Invitation Guide (Makerspace Opportunity)")
            self.setStrokeColor(BLACK)
            self.setLineWidth(0.6)
            self.line(54, 744, 612 - 54, 744)
            
        # Running Bottom Footer
        page_text = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(612 - 54, 34, page_text)
        self.drawString(54, 34, "University Makerspace & Project Opportunities Repository | AgriLink Initiative")
        self.setStrokeColor(BLACK)
        self.setLineWidth(0.6)
        self.line(54, 46, 612 - 54, 46)
        self.restoreState()

def create_section_header(number, title, styles):
    content = [
        Spacer(1, 6),
        Table(
            [[
                Paragraph(f"<font color='white'><b>{number}</b></font>", styles['BadgeStyle']),
                Paragraph(f"<b>{title}</b>", styles['SectionHeading'])
            ]],
            colWidths=[20, 484],
            style=TableStyle([
                ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
                ('BACKGROUND', (0, 0), (0, 0), BLACK),
                ('ALIGN', (0, 0), (0, 0), 'CENTER'),
                ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
                ('TOPPADDING', (0, 0), (-1, -1), 2),
                ('LEFTPADDING', (0, 0), (-1, -1), 2),
                ('RIGHTPADDING', (0, 0), (-1, -1), 2),
            ])
        ),
        Spacer(1, 2),
        HRFlowable(width="100%", thickness=0.8, color=BLACK, spaceBefore=2, spaceAfter=5)
    ]
    return content

def create_bw_box(text, title=None, styles=None):
    flowables = []
    if title:
        flowables.append(Paragraph(f"<b>{title}</b>", styles['BoxTitle']))
    flowables.append(Paragraph(text, styles['BoxBody']))
    t = Table([[flowables]], colWidths=[504])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), VERY_LIGHT_GRAY),
        ('BOX', (0, 0), (-1, -1), 1, BLACK),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ]))
    return t

def create_placeholder_box(title, dimensions_text, height=1.6*inch, styles=None):
    p_title = Paragraph(f"<b>[ {title.upper()} ]</b>", styles['PlaceholderTitle'])
    p_sub = Paragraph(f"<i>(Blank area reserved for visuals: {dimensions_text})</i>", styles['PlaceholderSub'])
    p_instruct = Paragraph("Paste prototype screenshots, hardware photos, fieldwork pictures, or demo QR codes here.", styles['PlaceholderInstruct'])
    t = Table([[p_title], [p_sub], [Spacer(1, 15)], [p_instruct]], colWidths=[504], rowHeights=[14, 12, height - 56, 14])
    t.setStyle(TableStyle([
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('BOX', (0, 0), (-1, -1), 1, BLACK),
        ('BACKGROUND', (0, 0), (-1, -1), WHITE),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    return t

def build_pdf():
    doc = SimpleDocTemplate(
        PDF_PATH,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    styles.add(ParagraphStyle(
        name='DocTitle',
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=BLACK,
        alignment=1,
        spaceAfter=4
    ))

    styles.add(ParagraphStyle(
        name='DocSubtitle',
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=14,
        textColor=DARK_GRAY,
        alignment=1,
        spaceAfter=3
    ))

    styles.add(ParagraphStyle(
        name='DocMeta',
        fontName='Helvetica',
        fontSize=8.5,
        leading=11,
        textColor=MID_GRAY,
        alignment=1,
        spaceAfter=8
    ))

    styles.add(ParagraphStyle(
        name='BadgeStyle',
        fontName='Helvetica-Bold',
        fontSize=9,
        leading=11,
        alignment=1,
        textColor=WHITE
    ))

    styles.add(ParagraphStyle(
        name='SectionHeading',
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=13.5,
        textColor=BLACK,
        leftIndent=4
    ))

    styles.add(ParagraphStyle(
        name='SubHeading',
        fontName='Helvetica-Bold',
        fontSize=9,
        leading=12,
        textColor=BLACK,
        spaceBefore=4,
        spaceAfter=2
    ))

    styles.add(ParagraphStyle(
        name='BodyCustom',
        fontName='Helvetica',
        fontSize=8.5,
        leading=11.5,
        textColor=BLACK,
        spaceAfter=4
    ))

    styles.add(ParagraphStyle(
        name='BulletCustom',
        fontName='Helvetica',
        fontSize=8.5,
        leading=11.5,
        textColor=BLACK,
        leftIndent=12,
        firstLineIndent=-8,
        spaceAfter=2.5
    ))

    styles.add(ParagraphStyle(
        name='BoxTitle',
        fontName='Helvetica-Bold',
        fontSize=9,
        leading=11.5,
        textColor=BLACK,
        spaceAfter=2
    ))

    styles.add(ParagraphStyle(
        name='BoxBody',
        fontName='Helvetica',
        fontSize=8.5,
        leading=11.5,
        textColor=BLACK
    ))

    styles.add(ParagraphStyle(
        name='TableHeader',
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10.5,
        textColor=WHITE,
        alignment=1
    ))

    styles.add(ParagraphStyle(
        name='TableCell',
        fontName='Helvetica',
        fontSize=8,
        leading=10.5,
        textColor=BLACK,
        alignment=0
    ))

    styles.add(ParagraphStyle(
        name='TableCellBold',
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10.5,
        textColor=BLACK,
        alignment=0
    ))

    styles.add(ParagraphStyle(
        name='PlaceholderTitle',
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=12,
        textColor=BLACK,
        alignment=1
    ))

    styles.add(ParagraphStyle(
        name='PlaceholderSub',
        fontName='Helvetica-Oblique',
        fontSize=8,
        leading=10,
        textColor=MID_GRAY,
        alignment=1
    ))

    styles.add(ParagraphStyle(
        name='PlaceholderInstruct',
        fontName='Helvetica',
        fontSize=7.5,
        leading=9.5,
        textColor=MID_GRAY,
        alignment=1
    ))

    story = []

    # ==================== BANNER / DOCUMENT HEADER ====================
    story.append(Paragraph("AGRILINK: DIRECT FARM-TO-COMMUNITY SUPPLY PLATFORM", styles['DocTitle']))
    story.append(Paragraph("Makerspace Project Handover & Interdisciplinary Student Invitation Guide", styles['DocSubtitle']))
    story.append(Paragraph("Open for Students from All Disciplines | Academic Year 2026", styles['DocMeta']))
    
    welcome_banner = create_bw_box(
        "<b>Welcome to the AgriLink Project:</b> AgriLink connects local farmers directly to retail customers, university hostels, hospitals, and local restaurants. Whether you are interested in software, electronics, business strategy, user design, photography, logistics, or biology—<b>you do not need to be a programmer or engineer to contribute.</b> This document explains what we are doing, what we have built so far, and how you can get involved.",
        "PROJECT OPPORTUNITY & INVITATION SUMMARY",
        styles
    )
    story.append(welcome_banner)
    story.append(Spacer(1, 4))

    # ==================== 1. PROJECT TITLE ====================
    story.extend(create_section_header(1, "Project Title", styles))
    story.append(Paragraph("<b>Project Name:</b> AgriLink — Smart Farm-to-Customer Supply & Recommendation Platform", styles['BodyCustom']))
    story.append(Paragraph("<b>Core Focus:</b> Connecting rural farmers and agricultural aggregator hubs directly to consumers, cutting out unfair middlemen, reducing food waste, and making fresh farm produce affordable and transparent.", styles['BodyCustom']))

    # ==================== 2. THE PROBLEM ====================
    story.extend(create_section_header(2, "The Problem", styles))
    story.append(Paragraph("Our current agricultural supply chain has several major real-world challenges:", styles['BodyCustom']))
    story.append(Paragraph("• <b>Too Many Middlemen:</b> Produce passes through 4 to 6 intermediaries before reaching consumers. As a result, farmers receive only 20–30% of the final price, while consumers pay high prices.", styles['BulletCustom']))
    story.append(Paragraph("• <b>High Food Wastage:</b> Because of delays, lack of cold-chain monitoring, and poor demand planning, 25% to 35% of harvested fruits and vegetables spoil before they reach buyers.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Lack of Information:</b> Farmers rarely know what local institutions (hostels, hospitals, restaurants) need on a daily basis, and buyers have no way of knowing how fresh their food actually is or where it came from.", styles['BulletCustom']))

    # ==================== 3. WHY DOES THIS MATTER? ====================
    story.extend(create_section_header(3, "Why Does This Matter?", styles))
    story.append(Paragraph("Agriculture supports more than half of the country's population, yet farming families face high economic uncertainty. Working on this project allows students to:", styles['BodyCustom']))
    story.append(Paragraph("• <b>Create Real-World Social Impact:</b> Fair pricing directly improves farmer livelihoods and lowers food costs for student messes and local families.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Reduce Environmental Waste:</b> Better matching of supply and demand prevents nutritious food from ending up in landfills.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Gain Multi-Disciplinary Experience:</b> Work with peers across departments on practical challenges that blend technology, market economics, design, and rural operations.", styles['BulletCustom']))

    # ==================== 4. OUR IDEA / PROPOSED SOLUTION ====================
    story.extend(create_section_header(4, "Our Idea / Proposed Solution", styles))
    story.append(Paragraph("AgriLink is an open, easy-to-use digital ecosystem that connects all stakeholders in one transparent loop:", styles['BodyCustom']))
    story.append(Paragraph("1. <b>For Farmers:</b> A simple portal to list their harvested crops, view fair market prices, and receive direct bulk orders from nearby buyers.", styles['BodyCustom']))
    story.append(Paragraph("2. <b>For Rural Aggregator Hubs:</b> Facilities where smallholder crops are gathered, checked for quality, safely packed, and prepared for dispatch.", styles['BodyCustom']))
    story.append(Paragraph("3. <b>For Customers & Institutions:</b> An intuitive app/website to browse fresh produce, view harvest freshness, join group orders (bulk buying for hostels/apartments), and schedule recurring meal deliveries.", styles['BodyCustom']))
    story.append(Paragraph("4. <b>Smart Matching:</b> Recommending specific nearby harvest batches based on harvest date, distance, quality grade, and buyer preferences.", styles['BodyCustom']))

    # ==================== 5. WHAT DO WE NEED? ====================
    story.extend(create_section_header(5, "What Do We Need?", styles))
    story.append(Paragraph("The project brings together different kinds of resources and expertise across five areas:", styles['BodyCustom']))

    need_data = [
        [Paragraph("<b>Area</b>", styles['TableHeader']), Paragraph("<b>What We Need</b>", styles['TableHeader']), Paragraph("<b>Examples in the Project</b>", styles['TableHeader'])],
        [Paragraph("<b>Software & Digital</b>", styles['TableCellBold']), Paragraph("Applications, databases, and analysis tools", styles['TableCell']), Paragraph("User apps, order management, smart search, and recommendation feeds.", styles['TableCell'])],
        [Paragraph("<b>Hardware & Devices</b>", styles['TableCellBold']), Paragraph("Sensors, development boards, and components", styles['TableCell']), Paragraph("Temperature/freshness crate trackers, digital weighing scales, and inspection cameras.", styles['TableCell'])],
        [Paragraph("<b>Data & Information</b>", styles['TableCellBold']), Paragraph("Datasets, surveys, and real-world numbers", styles['TableCell']), Paragraph("Mandi crop prices, hostel food consumption logs, buyer preferences, and harvest cycles.", styles['TableCell'])],
        [Paragraph("<b>Design & Creative</b>", styles['TableCellBold']), Paragraph("Visuals, interfaces, videos, and branding", styles['TableCell']), Paragraph("Clean mobile screens, user journey maps, instructional posters, and explainer videos.", styles['TableCell'])],
        [Paragraph("<b>Research & Business</b>", styles['TableCellBold']), Paragraph("Reports, business plans, and user studies", styles['TableCell']), Paragraph("Cost-benefit analysis, farmer interviews, logistics planning, and policy reviews.", styles['TableCell'])],
    ]
    t_need = Table(need_data, colWidths=[100, 180, 224])
    t_need.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), BLACK),
        ('GRID', (0, 0), (-1, -1), 0.5, BLACK),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, VERY_LIGHT_GRAY]),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ]))
    story.append(t_need)

    # ==================== 6. HOW DOES IT WORK? ====================
    story.extend(create_section_header(6, "How Does It Work?", styles))
    story.append(Paragraph("At a high level, the project follows a clear, continuous development lifecycle:", styles['BodyCustom']))

    flow_box = create_bw_box(
        "<b>Real-World Problem</b> (High food waste & low farmer earnings)<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;↓<br/>"
        "<b>Our Idea</b> (Direct digital marketplace linking farmers, aggregators & buyers)<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;↓<br/>"
        "<b>Working Prototype</b> (Cross-platform app, order flow & batch freshness matching)<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;↓<br/>"
        "<b>Testing & Feedback</b> (Testing with hostels, local mess managers & student buyers)<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;↓<br/>"
        "<b>Improvement & Expansion</b> (New features, IoT sensors, vernacular voice & business model)<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;↓<br/>"
        "<b>Real-World Impact</b> (Fairer earnings, fresher food & sustainable campus procurement)",
        "PROJECT PROCESS & WORKFLOW",
        styles
    )
    story.append(flow_box)

    # ==================== 7. WHERE ARE WE NOW? ====================
    story.extend(create_section_header(7, "Where Are We Now?", styles))
    story.append(Paragraph("<b>Current Stage Overview:</b> Idea &nbsp;→&nbsp; <b>[ Working Prototype ]</b> &nbsp;→&nbsp; Testing &nbsp;→&nbsp; Campus Pilot &nbsp;→&nbsp; Deployment", styles['BodyCustom']))
    story.append(Spacer(1, 2))

    status_data = [
        [Paragraph("<b>Stage</b>", styles['TableHeader']), Paragraph("<b>Current Status</b>", styles['TableHeader']), Paragraph("<b>What This Means</b>", styles['TableHeader'])],
        [Paragraph("<b>Core Prototype</b>", styles['TableCellBold']), Paragraph("[ COMPLETED ]", styles['TableCellBold']), Paragraph("The foundational system is fully built and working on test data.", styles['TableCell'])],
        [Paragraph("<b>User Testing</b>", styles['TableCellBold']), Paragraph("[ IN PROGRESS ]", styles['TableCellBold']), Paragraph("Gathering user experience feedback and verifying ordering workflows.", styles['TableCell'])],
        [Paragraph("<b>New Features</b>", styles['TableCellBold']), Paragraph("[ OPEN FOR STUDENTS ]", styles['TableCellBold']), Paragraph("Many new extensions in software, design, hardware, and business are ready to be built.", styles['TableCell'])],
    ]
    t_status = Table(status_data, colWidths=[110, 130, 264])
    t_status.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), BLACK),
        ('GRID', (0, 0), (-1, -1), 0.5, BLACK),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, VERY_LIGHT_GRAY]),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
    ]))
    story.append(t_status)

    # ==================== 8. WHAT HAVE WE BUILT? ====================
    story.extend(create_section_header(8, "What Have We Built?", styles))
    story.append(Paragraph("The team has already constructed a functioning system prototype containing:", styles['BodyCustom']))
    story.append(Paragraph("• <b>User-Friendly Marketplace App:</b> A clean interface where buyers can sign in, search for vegetables, fruits, and grains, filter by freshness and location, and place orders.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Farmer & Aggregator Portals:</b> Screens for farmers to upload available harvest quantities, set prices, and see incoming requests.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Smart Recommendation Engine:</b> Automatically suggests best-fit crop listings based on proximity, harvest freshness percentage, and buyer preferences.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Live Verification Test:</b> An automated test suite demonstrating sub-second response times across all services.", styles['BulletCustom']))

    # ==================== 9. WHAT HAS BEEN COMPLETED? ====================
    story.extend(create_section_header(9, "What Has Been Completed?", styles))
    
    chk_data = [
        [Paragraph("<b>Completed Work Items</b>", styles['TableHeader']), Paragraph("<b>Currently Active Work Items</b>", styles['TableHeader'])],
        [
            Paragraph(
                "[x] Initial problem definition & user research<br/>"
                "[x] Database structure with 100+ sample crop records<br/>"
                "[x] Core marketplace application & role logins<br/>"
                "[x] Recommendation model comparison & evaluation<br/>"
                "[x] Comprehensive technical report & architecture documentation",
                styles['TableCell']
            ),
            Paragraph(
                "[ ] Designing new user interfaces & onboarding graphics<br/>"
                "[ ] Collecting campus hostel & canteen buying requirements<br/>"
                "[ ] Testing physical crate sensors in the makerspace<br/>"
                "[ ] Creating pitch decks and competition demonstration videos<br/>"
                "[ ] Expanding regional language voice support for farmers",
                styles['TableCell']
            )
        ]
    ]
    t_chk = Table(chk_data, colWidths=[252, 252])
    t_chk.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), BLACK),
        ('GRID', (0, 0), (-1, -1), 0.5, BLACK),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE]),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(t_chk)

    # ==================== 10. WHAT CAN STUDENTS WORK ON NEXT? ====================
    story.extend(create_section_header(10, "What Can Students Work On Next?", styles))
    story.append(Paragraph("We have structured upcoming tasks by experience level so everyone can start comfortably:", styles['BodyCustom']))

    tasks_data = [
        [Paragraph("<b>Skill Level</b>", styles['TableHeader']), Paragraph("<b>Exciting Tasks & Projects You Can Take Up</b>", styles['TableHeader'])],
        [
            Paragraph("<b>Beginner-Friendly</b><br/><i>(No coding required)</i>", styles['TableCellBold']),
            Paragraph(
                "• Interview campus hostel/mess managers about their vegetable ordering needs.<br/>"
                "• Conduct user surveys on mobile app usability and ease of navigation.<br/>"
                "• Design posters, branding assets, and project presentation slide decks.<br/>"
                "• Test the current mobile app and record usability feedback or bug reports.<br/>"
                "• Create short demonstration videos and visual guides for new users.",
                styles['TableCell']
            )
        ],
        [
            Paragraph("<b>Intermediate</b><br/><i>(Basic tools / design / coding)</i>", styles['TableCellBold']),
            Paragraph(
                "• Redesign mobile app screens in Figma / Flutter for a smoother visual experience.<br/>"
                "• Analyze historical mandi market price trends and create visual dashboards.<br/>"
                "• Prototype a simple temperature & humidity sensor node in the makerspace.<br/>"
                "• Build a group-buying / split-bill feature for student hostel roommates.<br/>"
                "• Write user stories and documentation for campus competition submissions.",
                styles['TableCell']
            )
        ],
        [
            Paragraph("<b>Advanced</b><br/><i>(Specialized / technical / research)</i>", styles['TableCellBold']),
            Paragraph(
                "• Build a smartphone camera scanner to automatically detect fruit ripeness / defects.<br/>"
                "• Develop an intelligent route optimizer for multi-stop delivery vehicles.<br/>"
                "• Integrate local voice-to-text (vernacular speech) so farmers can speak to list crops.<br/>"
                "• Implement blockchain / QR batch tracking for pesticide audit trails.<br/>"
                "• Author research papers for student symposiums and international conferences.",
                styles['TableCell']
            )
        ],
    ]
    t_tasks = Table(tasks_data, colWidths=[130, 374])
    t_tasks.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), BLACK),
        ('GRID', (0, 0), (-1, -1), 0.5, BLACK),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, VERY_LIGHT_GRAY]),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ]))
    story.append(t_tasks)

    # ==================== 11. WHO CAN CONTRIBUTE? ====================
    story.extend(create_section_header(11, "Who Can Contribute?", styles))
    
    inclusive_box = create_bw_box(
        "<b>Important Principle:</b> You do <u>not</u> need to be a computer science student or have coding experience to make a valuable contribution. Real projects need diverse minds: researchers, designers, business analysts, domain enthusiasts, communicators, and builders alike.",
        "A MULTI-DISCIPLINARY INVITATION",
        styles
    )
    story.append(inclusive_box)
    story.append(Spacer(1, 4))

    story.append(Paragraph("<b>Three Broad Ways to Contribute:</b>", styles['SubHeading']))
    
    three_areas_data = [
        [Paragraph("<b>Track</b>", styles['TableHeader']), Paragraph("<b>Interest Areas</b>", styles['TableHeader']), Paragraph("<b>Example Contributions</b>", styles['TableHeader'])],
        [
            Paragraph("<b>1. Technology & Engineering</b>", styles['TableCellBold']),
            Paragraph("Software, Data, Electronics, Testing, Hardware", styles['TableCell']),
            Paragraph("App features, database queries, sensors, automation scripts, and test cases.", styles['TableCell'])
        ],
        [
            Paragraph("<b>2. Design & Communication</b>", styles['TableCellBold']),
            Paragraph("UI/UX, Visual Design, Video, Writing, Social Media", styles['TableCell']),
            Paragraph("Figma prototypes, user journey diagrams, video demos, and presentations.", styles['TableCell'])
        ],
        [
            Paragraph("<b>3. Business, Research & Society</b>", styles['TableCellBold']),
            Paragraph("Economics, Finance, Surveys, Sustainability, Policy", styles['TableCell']),
            Paragraph("Cost-benefit models, user research surveys, market analysis, and case studies.", styles['TableCell'])
        ],
    ]
    t_three = Table(three_areas_data, colWidths=[120, 160, 224])
    t_three.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), BLACK),
        ('GRID', (0, 0), (-1, -1), 0.5, BLACK),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, VERY_LIGHT_GRAY]),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ]))
    story.append(t_three)
    story.append(Spacer(1, 4))

    story.append(Paragraph("<b>Contribution Guide by Academic Background:</b>", styles['SubHeading']))
    
    bg_data = [
        [Paragraph("<b>Student Background / Major</b>", styles['TableHeader']), Paragraph("<b>How You Can Contribute to AgriLink</b>", styles['TableHeader'])],
        [Paragraph("<b>Computer Science / IT</b>", styles['TableCellBold']), Paragraph("Build frontend features, backend APIs, mobile screens, and database optimizations.", styles['TableCell'])],
        [Paragraph("<b>Data Science / AI</b>", styles['TableCellBold']), Paragraph("Analyze crop datasets, improve recommendation algorithms, and train price predictors.", styles['TableCell'])],
        [Paragraph("<b>Electronics / ECE / EEE</b>", styles['TableCellBold']), Paragraph("Work with ESP32 sensor boards, temperature/humidity monitors, and crate GPS units.", styles['TableCell'])],
        [Paragraph("<b>Mechanical / Mechatronics</b>", styles['TableCellBold']), Paragraph("Design lightweight, shockproof, and ventilated produce crates and mounting mechanisms.", styles['TableCell'])],
        [Paragraph("<b>Design / Media / Animation</b>", styles['TableCellBold']), Paragraph("Create intuitive mobile interfaces, graphic posters, explainer videos, and branding.", styles['TableCell'])],
        [Paragraph("<b>Business / Management</b>", styles['TableCellBold']), Paragraph("Develop business models, study customer adoption, and create commercialization plans.", styles['TableCell'])],
        [Paragraph("<b>Finance / Economics</b>", styles['TableCellBold']), Paragraph("Conduct cost-benefit analysis, supply-demand pricing studies, and margin comparisons.", styles['TableCell'])],
        [Paragraph("<b>Biotechnology / Agriculture</b>", styles['TableCellBold']), Paragraph("Provide domain guidance on crop shelf life, organic certifications, and storage guidelines.", styles['TableCell'])],
        [Paragraph("<b>Humanities / Psychology</b>", styles['TableCellBold']), Paragraph("Conduct farmer usability studies, buyer behavior surveys, and social impact evaluations.", styles['TableCell'])],
        [Paragraph("<b>Any Discipline / First Years</b>", styles['TableCellBold']), Paragraph("Project management, documentation, testing, user feedback collection, and creative brainstorming.", styles['TableCell'])],
    ]
    t_bg = Table(bg_data, colWidths=[150, 354])
    t_bg.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), BLACK),
        ('GRID', (0, 0), (-1, -1), 0.5, BLACK),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, VERY_LIGHT_GRAY]),
        ('TOPPADDING', (0, 0), (-1, -1), 2.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2.5),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ]))
    story.append(t_bg)

    # ==================== 12. WHERE CAN THIS BE USED IN COURSES? ====================
    story.extend(create_section_header(12, "How Can This Connect to Courses?", styles))
    story.append(Paragraph("Students can use AgriLink work to earn course credits, mini-projects, assignments, and capstone milestones:", styles['BodyCustom']))

    course_data = [
        [Paragraph("<b>Curriculum Area</b>", styles['TableHeader']), Paragraph("<b>Example Project / Assignment Deliverable</b>", styles['TableHeader'])],
        [Paragraph("<b>Programming & Web / Mobile</b>", styles['TableCellBold']), Paragraph("Implement a new user screen, cart checkout, or notifications system.", styles['TableCell'])],
        [Paragraph("<b>Data Analysis & Statistics</b>", styles['TableCellBold']), Paragraph("Perform statistical analysis on buyer trends and seasonal crop demand.", styles['TableCell'])],
        [Paragraph("<b>Hardware & IoT Labs</b>", styles['TableCellBold']), Paragraph("Assemble and calibrate an environmental monitoring crate module.", styles['TableCell'])],
        [Paragraph("<b>Human-Computer Interaction (HCI)</b>", styles['TableCellBold']), Paragraph("Conduct heuristic evaluation and usability testing on farmer interfaces.", styles['TableCell'])],
        [Paragraph("<b>Supply Chain & Logistics</b>", styles['TableCellBold']), Paragraph("Model aggregator collection routes and compute transportation cost savings.", styles['TableCell'])],
        [Paragraph("<b>Marketing & Entrepreneurship</b>", styles['TableCellBold']), Paragraph("Develop a go-to-market plan for campus hostels and local neighborhood clusters.", styles['TableCell'])],
        [Paragraph("<b>Technical Writing & Research</b>", styles['TableCellBold']), Paragraph("Prepare comprehensive project dissertations, research papers, or user manuals.", styles['TableCell'])],
    ]
    t_course = Table(course_data, colWidths=[160, 344])
    t_course.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), BLACK),
        ('GRID', (0, 0), (-1, -1), 0.5, BLACK),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, VERY_LIGHT_GRAY]),
        ('TOPPADDING', (0, 0), (-1, -1), 2.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2.5),
    ]))
    story.append(t_course)

    # ==================== 13. COMPETITIONS, RESEARCH & OPPORTUNITIES ====================
    story.extend(create_section_header(13, "Competitions, Research & Other Opportunities", styles))
    story.append(Paragraph("Being part of AgriLink gives you a strong foundation to compete and showcase your achievements:", styles['BodyCustom']))
    story.append(Paragraph("• <b>Smart India Hackathon (SIH):</b> Fits national problem statements on smart agriculture, rural supply chains, and farmer welfare.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Innovation & Sustainability Contests:</b> Ready for AgriThon, UN SDG Youth Challenges, and campus entrepreneurship competitions.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Research Publications:</b> Empirical benchmark results and user studies can be developed into conference papers (IEEE/ACM/Springer).", styles['BulletCustom']))
    story.append(Paragraph("• <b>Campus Startup Opportunities:</b> Potential to incubate the platform as a real campus-to-farm procurement service.", styles['BulletCustom']))

    # ==================== 14. CURRENT TEAM & MENTORS ====================
    story.extend(create_section_header(14, "Current Team & Mentors", styles))
    
    team_table_data = [
        [Paragraph("<b>Role</b>", styles['TableHeader']), Paragraph("<b>Name / Department</b>", styles['TableHeader']), Paragraph("<b>Area of Guidance / Collaboration</b>", styles['TableHeader'])],
        [Paragraph("<b>Faculty Guide</b>", styles['TableCellBold']), Paragraph("Project Coordinator / Faculty Mentor", styles['TableCell']), Paragraph("Overall academic oversight and institutional coordination", styles['TableCell'])],
        [Paragraph("<b>Makerspace Mentor</b>", styles['TableCellBold']), Paragraph("Innovation Lab Coordinator", styles['TableCell']), Paragraph("Hardware tools, workspace access, and rapid prototyping", styles['TableCell'])],
        [Paragraph("<b>Senior Student Leads</b>", styles['TableCellBold']), Paragraph("AgriLink Founding Student Developers", styles['TableCell']), Paragraph("Architecture onboarding, peer mentorship, and codebase support", styles['TableCell'])],
        [Paragraph("<b>Open Student Roles</b>", styles['TableCellBold']), Paragraph("Open for 1st, 2nd, 3rd & 4th year students", styles['TableCell']), Paragraph("Development, research, design, business, and testing tracks", styles['TableCell'])],
    ]
    t_team = Table(team_table_data, colWidths=[120, 164, 220])
    t_team.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), BLACK),
        ('GRID', (0, 0), (-1, -1), 0.5, BLACK),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, VERY_LIGHT_GRAY]),
        ('TOPPADDING', (0, 0), (-1, -1), 2.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2.5),
    ]))
    story.append(t_team)

    # ==================== 15. WHAT IS ALREADY AVAILABLE? ====================
    story.extend(create_section_header(15, "What Is Already Available?", styles))
    story.append(Paragraph("You don't need to start from scratch. The project already provides comprehensive resources:", styles['BodyCustom']))
    story.append(Paragraph("• <b>Equipment & Tools:</b> ESP32 boards, sensors (temperature, humidity, soil), load cells, and 3D printing equipment in the makerspace.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Software & Platforms:</b> Fully configured development repository, working mobile app, API backend, and cloud database.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Knowledge & Data:</b> Clean datasets of crop varieties, price histories, synthetic customer interactions, and full research reports.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Workspace & Community:</b> Dedicated makerspace lab tables, collaborative discussion channels, and regular peer check-ins.", styles['BulletCustom']))

    # ==================== 16. PROJECT FILES & RESOURCES ====================
    story.extend(create_section_header(16, "Project Files & Resources", styles))
    story.append(Paragraph("All project assets are neatly organized and easy to navigate:", styles['BodyCustom']))

    files_data = [
        [Paragraph("<b>Resource</b>", styles['TableHeader']), Paragraph("<b>Location / Folder</b>", styles['TableHeader']), Paragraph("<b>Contents & Purpose</b>", styles['TableHeader'])],
        [Paragraph("<b>Application Frontend</b>", styles['TableCellBold']), Paragraph("<code>/lib/</code>", styles['TableCell']), Paragraph("All Flutter mobile and web screens, UI themes, and models.", styles['TableCell'])],
        [Paragraph("<b>API Backend</b>", styles['TableCellBold']), Paragraph("<code>/fastapi_backend/</code>", styles['TableCell']), Paragraph("FastAPI server handling listings, orders, and recommendations.", styles['TableCell'])],
        [Paragraph("<b>Data & Models</b>", styles['TableCellBold']), Paragraph("<code>/ML_Benchmark/</code>", styles['TableCell']), Paragraph("Datasets, model benchmarking code, and performance charts.", styles['TableCell'])],
        [Paragraph("<b>Database Schemas</b>", styles['TableCellBold']), Paragraph("<code>/Backend/database/</code>", styles['TableCell']), Paragraph("SQL migration files and 100+ sample seed data entries.", styles['TableCell'])],
        [Paragraph("<b>Academic Report</b>", styles['TableCellBold']), Paragraph("<code>/Academic_Project_Report/</code>", styles['TableCell']), Paragraph("Detailed project report docx and reference documentation.", styles['TableCell'])],
    ]
    t_files = Table(files_data, colWidths=[120, 140, 244])
    t_files.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), BLACK),
        ('GRID', (0, 0), (-1, -1), 0.5, BLACK),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, VERY_LIGHT_GRAY]),
        ('TOPPADDING', (0, 0), (-1, -1), 2.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2.5),
    ]))
    story.append(t_files)

    # ==================== 17. HOW CAN YOU GET STARTED? ====================
    story.extend(create_section_header(17, "How Can You Get Started?", styles))
    
    start_box = create_bw_box(
        "<b>Step 1: Understand the Project:</b> Read through this guide to see the big picture and identify what interests you.<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;↓<br/>"
        "<b>Step 2: Choose Your Area of Interest:</b> Pick an area you'd like to explore (e.g., Design, Surveys, App Features, Sensors, or Business).<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;↓<br/>"
        "<b>Step 3: Meet the Team & Mentors:</b> Visit the makerspace or reach out to the project leads to discuss your chosen track.<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;↓<br/>"
        "<b>Step 4: Start with a Small, Guided Task:</b> Begin with an easy starter activity to gain confidence and gradually take on bigger challenges.",
        "4-STEP EASY ONBOARDING PROCESS",
        styles
    )
    story.append(start_box)
    story.append(Spacer(1, 3))
    story.append(Paragraph("<b>Note:</b> No prior experience is required for many project activities. We will guide you step by step!", styles['BodyCustom']))

    # ==================== 18. WHY JOIN THIS PROJECT? ====================
    story.extend(create_section_header(18, "Why Join This Project?", styles))
    story.append(Paragraph("Joining AgriLink offers significant personal and professional value for your college journey:", styles['BodyCustom']))
    story.append(Paragraph("• <b>Practical Portfolio Experience:</b> Build tangible artifacts (designs, hardware, software, or market studies) to showcase on your CV and LinkedIn.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Cross-Disciplinary Teamwork:</b> Learn how to collaborate effectively with students outside your immediate branch or year.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Hackathon & Competition Mentorship:</b> Receive active mentoring from seniors and faculty for prestigious national competitions.", styles['BulletCustom']))
    story.append(Paragraph("• <b>Leadership & Initiative:</b> Take ownership of independent sub-tracks and lead project milestones.", styles['BulletCustom']))

    # ==================== 19. PHOTOS / VIDEOS (BLANK VISUAL FRAMES) ====================
    story.append(PageBreak())
    story.extend(create_section_header(19, "Photos & Demonstration Visuals", styles))
    story.append(Paragraph("Reserved blank visual layout sections for team photos, application screenshots, hardware prototypes, and demo links:", styles['BodyCustom']))
    story.append(Spacer(1, 4))

    box1 = create_placeholder_box("Visual 1: Mobile & Web Application Interface", "Recommended size: 500 x 180 px", height=1.6*inch, styles=styles)
    box2 = create_placeholder_box("Visual 2: Makerspace Hardware Prototype / Fieldwork Photos", "Recommended size: 500 x 180 px", height=1.6*inch, styles=styles)
    box3 = create_placeholder_box("Visual 3: Project Demonstration Video QR Code / Poster", "Recommended size: 500 x 150 px", height=1.35*inch, styles=styles)

    story.append(KeepTogether(box1))
    story.append(Spacer(1, 6))
    story.append(KeepTogether(box2))
    story.append(Spacer(1, 6))
    story.append(KeepTogether(box3))
    story.append(Spacer(1, 6))

    # Final Closing Invitation Box
    final_banner = create_bw_box(
        "<b>Ready to Join?</b> Reach out to the Faculty Project Guide or drop by the Makerspace Innovation Lab. Every contribution—big or small, technical or creative—makes a real difference in empowering local farming communities!",
        "JOIN THE AGRILINK TEAM TODAY",
        styles
    )
    story.append(final_banner)

    doc.build(story, canvasmaker=MonochromeNumberedCanvas)
    print(f"[SUCCESS] Rebuilt Makerspace Invitation PDF successfully generated!")
    print(f"PDF Location: {PDF_PATH}")

if __name__ == "__main__":
    build_pdf()
