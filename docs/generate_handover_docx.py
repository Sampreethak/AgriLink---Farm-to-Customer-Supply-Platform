import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def create_element(name):
    return OxmlElement(name)

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def add_page_number_to_section(doc):
    pass

def generate_docx():
    doc = Document()
    
    # Page setup - 0.75 inch margins
    sections = doc.sections
    for section in sections:
        section.top_margin = Inches(0.75)
        section.bottom_margin = Inches(0.75)
        section.left_margin = Inches(0.75)
        section.right_margin = Inches(0.75)

    # Style colors
    PRIMARY_COLOR = RGBColor(34, 112, 62) # Forest Green
    DARK_TEXT = RGBColor(30, 41, 59)
    GRAY_TEXT = RGBColor(100, 116, 139)

    # Normal Style
    normal_style = doc.styles['Normal']
    normal_font = normal_style.font
    normal_font.name = 'Segoe UI'
    normal_font.size = Pt(10.5)
    normal_font.color.rgb = DARK_TEXT

    # Title
    title_p = doc.add_paragraph()
    title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title_run = title_p.add_run("PROJECT LEGACY & HANDOVER DOCUMENT")
    title_run.font.name = 'Segoe UI'
    title_run.font.size = Pt(20)
    title_run.font.bold = True
    title_run.font.color.rgb = PRIMARY_COLOR
    title_p.paragraph_format.space_after = Pt(2)

    sub_p = doc.add_paragraph()
    sub_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    sub_run = sub_p.add_run("Knowledge Transfer from Graduating Batch to the Next Student Team")
    sub_run.font.name = 'Segoe UI'
    sub_run.font.size = Pt(12)
    sub_run.font.italic = True
    sub_run.font.color.rgb = GRAY_TEXT
    sub_p.paragraph_format.space_after = Pt(12)

    # Info Box
    info_table = doc.add_table(rows=2, cols=2)
    info_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    info_table.autofit = False

    info_data = [
        [("Project Name:", " AgriLink — Intelligent Farm-to-Customer Supply & Advisory Platform"), ("Project Domain:", " [x] IoT  [x] AI  [x] ML")],
        [("Target Corridor:", " Mandya ➔ North Bengaluru Corridor"), ("Repository Path:", " c:\\Users\\Samskrutha\\Desktop\\agrilink_github")]
    ]

    for r_idx, row in enumerate(info_table.rows):
        for c_idx, cell in enumerate(row.cells):
            set_cell_background(cell, "F1F5F9")
            set_cell_margins(cell, top=80, bottom=80, left=120, right=120)
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(2)
            lbl, val = info_data[r_idx][c_idx]
            r1 = p.add_run(lbl)
            r1.bold = True
            r1.font.size = Pt(9.5)
            r2 = p.add_run(val)
            r2.font.size = Pt(9.5)

    doc.add_paragraph().paragraph_format.space_after = Pt(8)

    # 4-Page Overview Table
    heading_table = doc.add_heading("📑 Handover Structure at a Glance", level=2)
    heading_table.style.font.color.rgb = PRIMARY_COLOR

    struct_table = doc.add_table(rows=5, cols=3)
    struct_table.alignment = WD_TABLE_ALIGNMENT.CENTER

    headers = ["Page", "Major Heading", "Included Sections"]
    hdr_cells = struct_table.rows[0].cells
    for i, title in enumerate(headers):
        hdr_cells[i].text = title
        set_cell_background(hdr_cells[i], "166534") # Dark Green
        p = hdr_cells[i].paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        for run in p.runs:
            run.font.bold = True
            run.font.color.rgb = RGBColor(255, 255, 255)
            run.font.size = Pt(10)

    rows_data = [
        ("Page 1", "PROJECT & PROBLEM", "1. Project Overview -> 2. Problem Statement & Objectives -> 3. Project Evolution & Contributions"),
        ("Page 2", "SYSTEM & TECHNOLOGY", "4. Existing Solution -> 5. Architecture & Modules -> 6. Technology Stack -> 7. AI/ML/DL/MML/RL -> 8. Full Stack"),
        ("Page 3", "IMPLEMENTATION & ACHIEVEMENTS", "9. Current Status -> 10. Research & Academic Contributions -> 11. Repository & Resources"),
        ("Page 4", "HANDOVER & FUTURE WORK", "12. Challenges & Lessons -> 13. Future Scope -> 14. Handover Plan -> 15. Team Information")
    ]

    for r_idx, (p_num, m_head, secs) in enumerate(rows_data, start=1):
        row_cells = struct_table.rows[r_idx].cells
        bg_color = "F8FAFC" if r_idx % 2 == 1 else "FFFFFF"
        for c_idx, text in enumerate([p_num, m_head, secs]):
            row_cells[c_idx].text = text
            set_cell_background(row_cells[c_idx], bg_color)
            set_cell_margins(row_cells[c_idx], top=80, bottom=80, left=120, right=120)
            p = row_cells[c_idx].paragraphs[0]
            p.paragraph_format.space_after = Pt(2)
            if c_idx < 2:
                for run in p.runs:
                    run.font.bold = True
                    run.font.size = Pt(9.5)

    doc.add_page_break()

    # Content Pages Definition
    pages_content = [
        {
            "page_title": "PAGE 1: PROJECT & PROBLEM",
            "sections": [
                ("1. Project Overview", [
                    "AgriLink is an intelligent digital marketplace and supply chain platform connecting smallholder rural farmers directly with urban buyers, institutional canteens, and apartment communities. By removing middleman brokers and unorganized wholesale channels, AgriLink establishes a direct supply pipeline for fresh agricultural produce.",
                    "The platform provides a 4-in-1 digital solution:",
                    "• Farmer Digital Portal & Advisory: Enables rural growers to pre-register upcoming crop harvests and receive voice-guided farming advice in their native language (Kannada, Hindi, etc.).",
                    "• Rural Aggregation Hubs: Organizes local hubs where fresh produce is weighed, quality-graded (Grade A+, A, B), and packed efficiently.",
                    "• Smart Urban Marketplace: Offers buyers personalized crop recommendations, transparent prices, and direct farm origin tracking.",
                    "• Optimized Logistics Dispatch: Coordinates clean electric vehicles and local delivery riders to transfer produce from farm gate to kitchen within 12 hours."
                ]),
                ("2. Problem Statement & Objectives", [
                    "The Challenge in Traditional Agriculture:",
                    "Smallholder farmers in regions like Mandya face severe economic exploitation due to multi-layered commissions from village brokers, regional agents, and wholesale market traders.",
                    "• Low Farmer Income: Farmers capture only 25% to 35% of the end consumer rupee.",
                    "• Post-Harvest Spoilage: Transport delays and improper handling cause 22% to 30% spoilage in perishable produce.",
                    "• Information Barriers: Rural growers lack access to real-time market rates, demand forecasts, and scientific pest advisories in local dialects.",
                    "",
                    "Core Project Objectives:",
                    "• Fair Revenue Sharing (68-10-14-8 Model): Ensure 68% of retail prices go directly to the farmer, 10% to the rural aggregation hub, 14% to clean delivery logistics, and 8% to platform operations.",
                    "• Price Transparency: Calculate fair market prices using real-time market benchmarks combined with quality grades, organic status, and transit distance.",
                    "• Direct Buyer-Seller Matching: Reduce transit time to under 12 hours between harvest and consumer delivery.",
                    "• Voice-First Accessibility: Provide audio-based AI farming advice for rural users who prefer spoken language over text."
                ]),
                ("3. Project Evolution & Contributions", [
                    "Key Milestones & Contributions:",
                    "1. Requirements & Field Survey: Conducted field research across agricultural hubs in Mandya and consumer clusters in North Bengaluru (Hebbal, Yelahanka, Devanahalli). Defined functional specs for 5 user roles (FARMER, BUYER, AGGREGATOR, DELIVERY_AGENT, ADMIN).",
                    "2. Database Normalization & Schema: Engineered a clean 3NF/BCNF database schema in Supabase PostgreSQL with 18 core tables and over 4,250 verified seed entries.",
                    "3. Multi-Stack API Gateway: Developed FastAPI microservices in Python alongside alternative Node.js and Spring Boot Java backends.",
                    "4. AI & Machine Learning Integration: Built a hybrid recommendation engine (LightFM matrix factorization + TF-IDF content similarity) alongside a voice-based advisory chatbot framework.",
                    "5. Cross-Platform Mobile & Web App: Implemented a responsive Flutter app supporting tailored dashboard views for Farmers, Buyers, Aggregators, and Delivery Agents."
                ])
            ]
        },
        {
            "page_title": "PAGE 2: SYSTEM & TECHNOLOGY",
            "sections": [
                ("4. Existing Solution vs. AgriLink", [
                    "Traditional APMC Mandi System:",
                    "• 4 to 6 intermediary brokers extracting commissions at every stage.",
                    "• Farmers capture only 25%–35% of end consumer retail value.",
                    "• Opaque pricing, long 45-60 day payment delays, and high 25-30% transit spoilage.",
                    "",
                    "AgriLink Smart Marketplace:",
                    "• Direct farmer-to-buyer connection eliminating intermediary commission agents.",
                    "• Guaranteed 68% direct payout to farmers with dynamic fair-pricing formulas.",
                    "• Sub-12 hour transit (<8% spoilage), instant digital payouts, and 24/7 multilingual voice AI guidance."
                ]),
                ("5. Architecture & Modules", [
                    "System Architecture Overview:",
                    "• User Interaction Tier: Responsive Flutter application for Mobile (Android/iOS) and Web.",
                    "• API Gateway Tier: Asynchronous FastAPI server handling security, authentication, orders, and catalog management.",
                    "• Database Tier: Supabase PostgreSQL relational database with 18 live core tables.",
                    "• AI & Logistics Engines: LightFM matrix factorization recommender, multilingual speech RAG pipeline, and electric vehicle fleet dispatch routing.",
                    "",
                    "Core Operational Modules:",
                    "1. Farmer Module: Harvest pre-declaration, batch cataloging, earnings tracking, and voice advisory.",
                    "2. Buyer Module: Dynamic product catalog, personalized recommendations, cart checkout, and farm origin tracking.",
                    "3. Hub & Aggregation Module: Quality assay logging, sorting, crate tracking, and warehouse monitoring.",
                    "4. Logistics Module: Automated route assignment, EV fleet dispatch, and digital OTP proof-of-delivery."
                ]),
                ("6. Technology Stack & 7. AI/ML Engine & 8. Full Stack", [
                    "Technology Stack Breakdown:",
                    "• Frontend / Mobile: Flutter (Dart), HTML5 / CSS3 / JavaScript.",
                    "• Backend Frameworks: Python FastAPI (Primary production server), Node.js Express, Java Spring Boot.",
                    "• Database & Cloud: Supabase PostgreSQL (Relational schema with 18 core tables).",
                    "• AI & Machine Learning: LightFM (Collaborative Filtering), Scikit-Learn (TF-IDF Similarity), Whisper ASR (Speech-to-Text), IndicTrans2 (Translation), FAISS (Vector Index).",
                    "",
                    "Full Stack Integration & Data Flow:",
                    "1. Order Placement: Customer places order via Flutter storefront; FastAPI gateway checks stock.",
                    "2. Database Update: Supabase records transaction details and creates escrow payout balance.",
                    "3. Dispatch Trigger: System notifies nearest Aggregator Hub and dispatches available EV delivery rider.",
                    "4. Final Delivery: Delivery verified via customer OTP scan, immediately releasing funds to farmer's account."
                ])
            ]
        },
        {
            "page_title": "PAGE 3: IMPLEMENTATION & ACHIEVEMENTS",
            "sections": [
                ("9. Current Project Status", [
                    "Operational Assets & Completed Components:",
                    "• Live Cloud Database: Deployed on Supabase PostgreSQL with 18 normalized tables and 4,250+ entries across Mandya and North Bengaluru test corridors.",
                    "• Functional Flutter Application: Complete codebase for mobile and web clients with tailored screens for Farmers, Buyers, Hub Managers, and Delivery Riders.",
                    "• Operational REST APIs: FastAPI application running locally (http://127.0.0.1:8000/docs) serving authentication, catalog, order processing, and ML recommendations.",
                    "• Pre-trained AI Models: LightFM recommendation weights and TF-IDF search indices saved in ml/ folder ready for instant inference."
                ]),
                ("10. Research & Academic Contributions", [
                    "Key Research Highlights:",
                    "• Survey of 8 Domain Papers: Evaluated existing literature on agricultural query systems, speech LLMs, crop suitability prediction models, and cloud marketplaces.",
                    "• 68-10-14-8 Fair Distribution Model: Formulated sustainable economic revenue split ensuring 68% farmer payout, 10% hub fee, 14% logistics transport, and 8% platform operations.",
                    "• Dynamic Pricing Formula: Formulated fair pricing based on APMC market rates, quality grade premiums, organic certification, and transport distance."
                ]),
                ("11. Repository & Key Resources", [
                    "Repository Folder Structure:",
                    "• mobile_app/ : Flutter app codebase (Customer, Farmer, Hub, Admin screens).",
                    "• backend_fastapi/ : Primary Python API server & ML integration.",
                    "• ml/ : Recommendation algorithms, training scripts, and benchmarks.",
                    "• database/ : Supabase SQL scripts, tables, and seed dataset.",
                    "• docs/ : Comprehensive reports, SRS specifications, and handover blueprints.",
                    "",
                    "Live Resource URLs:",
                    "• Supabase Project: https://nxwhnbejvwxiuekhtmpm.supabase.co",
                    "• Local API Swagger Docs: http://127.0.0.1:8000/docs",
                    "• Local Flutter Web Server: http://127.0.0.1:8080"
                ])
            ]
        },
        {
            "page_title": "PAGE 4: HANDOVER & FUTURE WORK",
            "sections": [
                ("12. Challenges & Lessons Learned", [
                    "Key Operational Lessons:",
                    "1. Rural Network Connectivity: Variable mobile network in rural areas requires local offline caching, syncing data when connection resumes.",
                    "2. Perishable Batch Timing: Fresh agricultural produce spoils rapidly; real-time harvest timestamping prevents recommending older inventory.",
                    "3. Cold-Start Adaptation: New buyers with zero purchase history are served regional organic top-sellers until preference data accumulates.",
                    "4. Regional Accent Recognition: Spoken farming terminology requires specialized speech processing for regional Indian accents."
                ]),
                ("13. Future Scope & Enhancement Roadmap", [
                    "Future Upgrade Opportunities:",
                    "• IoT Cold-Chain Sensors: Deploy temperature and humidity sensors inside delivery crates and hub storage to track produce freshness in real time.",
                    "• Computer Vision Quality Scoring: Enable hub managers to take a crop photo for automated AI grade scoring (Grade A+, A, B).",
                    "• Blockchain Smart Contracts: Deploy automated smart contracts on Polygon for transparent payment release upon OTP delivery confirmation.",
                    "• Geographical Expansion: Expand operations beyond Mandya-Bengaluru to major agricultural belts across South India."
                ]),
                ("14. Handover Plan & 15. Team Breakdown", [
                    "Step-by-Step Setup Guide for Student Team:",
                    "1. Environment Setup: Clone repo and install Python requirements in backend_fastapi/.",
                    "2. Verify Database: Run database/00_run_all.sql or check live tables on Supabase Dashboard.",
                    "3. Start API Gateway: Run 'python -m uvicorn main:app --reload --port 8000' in backend_fastapi/.",
                    "4. Launch Flutter App: Run 'flutter run -d chrome' in mobile_app/.",
                    "5. Train AI Models: Execute 'python train_recommendation_model.py' inside ml/.",
                    "",
                    "Team Responsibilities:",
                    "• Person 1: Buyer app experience, Flutter screens, customer checkout UI.",
                    "• Person 2: Farmer app screens, FastAPI server endpoints, API logic.",
                    "• Person 3: Supabase database schema, LightFM recommendation models, voice advisory algorithms."
                ])
            ]
        }
    ]

    for p_idx, page in enumerate(pages_content):
        # Header banner for Page
        p_hdr = doc.add_heading(page["page_title"], level=1)
        p_hdr.style.font.color.rgb = PRIMARY_COLOR
        p_hdr.paragraph_format.space_before = Pt(12)
        p_hdr.paragraph_format.space_after = Pt(8)

        for sec_title, lines in page["sections"]:
            sec_hdr = doc.add_heading(sec_title, level=2)
            sec_hdr.style.font.color.rgb = DARK_TEXT
            sec_hdr.paragraph_format.space_before = Pt(8)
            sec_hdr.paragraph_format.space_after = Pt(4)

            for line in lines:
                if not line.strip():
                    doc.add_paragraph().paragraph_format.space_after = Pt(2)
                    continue
                p = doc.add_paragraph()
                p.paragraph_format.space_after = Pt(3)
                p.paragraph_format.line_spacing = 1.15
                if line.startswith("•") or line.startswith("1.") or line.startswith("2.") or line.startswith("3.") or line.startswith("4.") or line.startswith("5."):
                    p.paragraph_format.left_indent = Inches(0.2)
                
                # Check for bold prefixes
                if ":" in line and len(line.split(":")[0]) < 40 and not line.startswith("http"):
                    parts = line.split(":", 1)
                    r_bold = p.add_run(parts[0] + ":")
                    r_bold.bold = True
                    p.add_run(parts[1])
                else:
                    p.add_run(line)

        if p_idx < len(pages_content) - 1:
            doc.add_page_break()

    output_path = r"c:\Users\Samskrutha\Desktop\agrilink_github\docs\AgriLink_Legacy_Handover_Document.docx"
    doc.save(output_path)
    print("Successfully generated:", output_path)

if __name__ == "__main__":
    generate_docx()
