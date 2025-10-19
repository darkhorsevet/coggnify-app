# 🐴 Horsimize - AI Equine Nutrition Assistant

## Overview

**Horsimize** is an iOS app that helps horse owners make informed feeding decisions through AI-powered analysis. Built by an equine veterinarian who understands that most horse owners struggle with proper nutrition.

### The Problem
- Horse owners spend $300-500/month on feed but often don't know what they're feeding
- Body condition issues (too fat or too thin) are extremely common
- Feed stores give inconsistent advice
- Veterinarians are constantly saying "your horse is too fat/thin"
- Metabolic issues (IR, Cushing's, laminitis) require careful feed selection

### The Solution
Horsimize provides:
1. **Feed Tag Scanner** - OCR technology to read guaranteed analysis
2. **Body Condition Score Analysis** - Photo-based BCS assessment (1-9 scale)
3. **Smart Recommendations** - AI matches feeds to your horse's specific needs
4. **Feed Price Comparison** - Find the best feed for your budget
5. **Health Condition Support** - Special recommendations for IR, Cushing's, ulcers, etc.

---

## ✨ Features (MVP)

### 1. Horse Profile Management
- Add unlimited horses
- Track breed, age, weight, activity level
- Record health conditions (metabolic, Cushing's, laminitis, ulcers, etc.)
- Monitor body condition score over time
- Photo history

### 2. Feed Tag Scanner 📸
- **OCR Technology** - Point camera at feed bag tag
- Extracts: Protein %, Fat %, Fiber %, NSC %
- Matches to database of 20+ common feeds
- Instant nutritional analysis
- Works with any feed brand

### 3. Body Condition Score Analyzer 📊
- Take side-view photo of horse
- AI estimates BCS (1-9 scale)
- Manual adjustment available
- Track BCS changes over time
- Personalized recommendations
  - BCS 1-3: Underweight - increase feed
  - BCS 4-6: Ideal - maintain
  - BCS 7-9: Overweight - reduce grain

### 4. Smart Feed Recommendations 🎯
- **AI Recommendation Engine** considers:
  - Horse's activity level
  - Current body condition
  - Health conditions (IR, Cushing's, ulcers, etc.)
  - Age (senior, growing, mature)
  - Budget
- **5-Star Rating System**
- Pros & Cons for each feed
- Feeding guidelines (amount to feed)
- Monthly cost calculator

### 5. Feed Database 📚
- 20+ pre-loaded feeds:
  - Purina (Strategy, Omolene, Equine Senior)
  - Triple Crown (Low Starch, Senior, Growth)
  - SafeChoice (Original, Special Care, Senior)
  - Buckeye, Ration Balancers, and more
- Searchable and filterable
- Complete nutritional info
- Price comparison
- Special focus on NSC for metabolic horses

---

## 🎨 UI/UX Design

### Apple-Polished Interface
- **Native iOS** - SwiftUI for smooth performance
- **Tab Navigation** - 5 main tabs
- **Green Accent Color** - Horse/farm theme
- **Clean Cards** - Modern, readable layouts
- **Intuitive Icons** - Horse emoji, camera, charts
- **Dark Mode Ready** - System appearance support

### Main Tabs:
1. 🐴 **My Horses** - Horse profiles and management
2. 📸 **Scan Feed** - Feed tag scanner
3. 📊 **Body Score** - BCS photo analyzer
4. 📚 **Feed Library** - Browse all feeds
5. ⚙️ **Settings** - App preferences

---

## 🏗️ Technical Architecture

### Technologies
- **SwiftUI** - Modern iOS UI framework
- **Vision Framework** - OCR for feed tag scanning
- **AVFoundation** - Camera access
- **CoreML** (Future) - On-device BCS analysis model
- **Codable** - Data persistence

### Key Components

#### Models (`Models.swift`)
```swift
- Horse (profile with health conditions)
- Feed (nutritional database)
- BCSEntry (body condition history)
- FeedRecommendation (AI match results)
- ScannedFeedResult (OCR results)
```

#### Managers
- `HorseManager` - Horse CRUD operations
- `FeedDatabase` - 20+ feed database
- `FeedRecommendationEngine` - AI matching algorithm

#### Views
- `HorsesListView` - Horse profiles
- `AddHorseView` - Horse creation form
- `HorseDetailView` - Individual horse details
- `FeedScannerView` - OCR camera interface
- `BCSAnalyzerView` - Photo-based BCS tool
- `FeedRecommendationsView` - AI recommendations
- `FeedLibraryView` - Browse feeds
- `FeedDetailView` - Individual feed details

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+
- iPhone (camera required for scanning/BCS)

### Installation
1. Open `Horsimize.xcodeproj` in Xcode
2. Select your development team
3. Build and run on iPhone (simulator has limited camera)

### First Run
1. Add your first horse profile
2. Scan a feed bag tag (or browse feed library)
3. Take a body condition photo
4. Get personalized recommendations!

---

## 📊 Feed Database

### Included Feeds (20+)

**Purina:**
- Strategy Professional
- Omolene 200 (sweet feed)
- Equine Senior
- Enrich Plus Ration Balancer
- Ultium Competition

**Triple Crown:**
- Low Starch (NSC 11.5% - excellent for IR)
- Senior
- Growth
- 30% Ration Balancer
- Competitor

**SafeChoice:**
- Original
- Special Care (low NSC)
- Senior

**Buckeye:**
- Safe 'N Easy Senior
- Gro 'N Win

**Others:**
- Whole Oats, Cracked Corn
- Timothy Cubes, Alfalfa Pellets
- Beet Pulp Shreds

All feeds include:
- Protein %, Fat %, Fiber %
- NSC % (critical for metabolic horses)
- Calories per pound
- Price per bag and per pound
- Key ingredients

---

## 🤖 AI Recommendation Engine

### How It Works

The recommendation engine evaluates each feed based on:

#### Health Conditions
- **Metabolic/IR/Cushing's**: Prioritizes feeds with NSC < 12%
- **Laminitis History**: Avoids high-sugar feeds
- **Ulcers**: Recommends high-fiber feeds
- **EPSM/Tying Up**: Suggests low-NSC, high-fat feeds
- **Dental Issues**: Prefers pelleted/senior feeds

#### Activity Level
- **Maintenance**: Ration balancers or low-calorie feeds
- **Light Work**: Moderate energy feeds
- **Performance**: High-fat performance feeds
- **Senior**: Easy-to-chew, highly digestible feeds
- **Growing**: High protein growth formulas

#### Body Condition Score
- **BCS 1-3 (Too Thin)**: High-fat, high-calorie feeds
- **BCS 4-6 (Ideal)**: Maintain current program
- **BCS 7-9 (Overweight)**: Low-calorie, ration balancers

#### Age Considerations
- **Seniors (20+)**: Senior-specific formulas
- **Growing (0-3)**: Growth formulas with adequate protein
- **Breeding Mares**: Higher calorie requirements

### Rating System (1-5 Stars)
- ⭐⭐⭐⭐⭐ Excellent match
- ⭐⭐⭐⭐ Very good option
- ⭐⭐⭐ Suitable, consider alternatives
- ⭐⭐ Not ideal
- ⭐ Not recommended

---

## 💰 Business Model (Future)

### Freemium Structure

**FREE:**
- 1 horse profile
- Basic feed scanning
- BCS once per month
- Limited recommendations

**PREMIUM ($9.99/month):**
- Unlimited horses
- Unlimited scanning & BCS
- Full recommendation engine
- Price tracking & alerts
- Progress charts
- Export reports
- No ads

### Additional Revenue Streams
1. **Feed Company Partnerships**
   - Purina, Triple Crown pay for featured placement
   - $5,000-10,000/month per sponsor

2. **Affiliate Commissions**
   - Links to Tractor Supply, Chewy, Amazon
   - 5-10% commission on feed sales

3. **Vet Partnerships**
   - Veterinarians can recommend the app
   - White-label option for vet practices

### Market Size
- **180 million horses worldwide**
- **9.2 million horses in USA**
- **2 million horse owners in USA**
- Average spend: $300-500/month on feed

**If 100,000 users:**
- 10% premium = 10,000 x $9.99 = $99,900/month
- Feed partnerships = $20,000/month
- Affiliate revenue = $10,000/month
- **Total: $130,000/month revenue** 💰

---

## 🔮 Future Features (Post-MVP)

### Version 1.1
- [ ] Cloud sync (horses across devices)
- [ ] Feed price tracking & alerts
- [ ] Multiple photos per BCS entry
- [ ] Weight tracking with charts

### Version 1.2
- [ ] Supplement recommendations
- [ ] Hay analysis integration
- [ ] Feed schedule/reminders
- [ ] Shopping list generator

### Version 1.3
- [ ] Social features (share horses)
- [ ] Before/after photo comparisons
- [ ] Feed store locator
- [ ] Barcode scanning (UPC)

### Version 2.0
- [ ] Custom CoreML model for BCS (trained on thousands of horse photos)
- [ ] Integration with vet EMR systems
- [ ] Nutrition consultation booking
- [ ] Community forum

### Enterprise Features
- [ ] Barn management (multiple horses)
- [ ] Feeding schedules for staff
- [ ] Inventory tracking
- [ ] Cost analysis per horse

---

## 🎯 Target Users

### Primary: Backyard Horse Owners
- Own 1-3 horses
- Recreational riders
- Limited equine nutrition knowledge
- Budget-conscious
- **80% of market**

### Secondary: Small Barn Owners
- 4-10 horses
- Boarding facilities
- Need to manage multiple horses efficiently
- **15% of market**

### Tertiary: Professional Trainers
- 10+ horses
- Performance/competition focus
- Want data-driven feeding programs
- **5% of market**

---

## 🏆 Competitive Advantages

### Why Horsimize Wins

1. **Built by an Equine Vet** ✅
   - Credibility and expertise
   - Understands real problems
   - Trusted recommendations

2. **Simple & Focused** ✅
   - Not trying to do everything
   - Solves ONE problem really well
   - Easy to use for non-tech owners

3. **Photo-Based** ✅
   - Visual tools (scan tags, BCS photos)
   - More engaging than text input
   - Reduces user effort

4. **Actionable Recommendations** ✅
   - Not just data - tells you what to DO
   - Specific feeding amounts
   - Monthly cost estimates

5. **Offline-First for Feed Database** ✅
   - Works at the barn (no service)
   - Fast and responsive
   - 20 most common feeds pre-loaded

---

## 📱 Platform Strategy

### Phase 1: iOS Only (MVP)
- Focus on iPhone users
- Faster development
- Apple users more willing to pay
- Better for photos/camera features

### Phase 2: Android
- After iOS validation
- Port to Kotlin/Jetpack Compose
- Slightly different UX

### Phase 3: Web Dashboard
- View horses on desktop
- Print feed comparisons
- Analytics and charts

---

## 🧪 Testing Notes

### What Works (MVP)
- ✅ Horse profile creation
- ✅ Feed database browsing
- ✅ OCR feed tag scanning
- ✅ Mock BCS analysis (real AI coming)
- ✅ Recommendation engine
- ✅ Price calculations

### Coming Soon
- [ ] Real CoreML BCS model (need training data)
- [ ] Cloud persistence (currently local only)
- [ ] Push notifications for reminders
- [ ] Export to PDF

### Known Limitations (MVP)
- Data resets when app closes (no persistence yet)
- BCS analysis is mock (shows realistic results but not true AI)
- Camera simulator doesn't work (need real iPhone)
- Limited to 20 feeds (will expand to 100+)

---

## 🙏 Acknowledgments

**Built by:** An equine veterinarian who's tired of owners feeding their horses wrong 😅

**Inspired by:** Years of field calls saying "your horse is too fat" and "that feed is too hot for him"

**For:** Every backyard horse owner trying their best ❤️

---

## 📄 License

Proprietary - All rights reserved

---

## 📞 Contact

- **Website:** https://horsimize.com (coming soon)
- **Email:** support@horsimize.com
- **Instagram:** @horsimize

---

## 🚀 Launch Checklist

- [x] Build MVP
- [x] Test core features
- [ ] App Store submission
- [ ] Landing page
- [ ] Social media accounts
- [ ] First 100 beta testers
- [ ] Vet testimonials
- [ ] Press release
- [ ] Launch! 🎉

---

**Built with ❤️ for horse owners everywhere 🐴**

*"Finally, an app that understands my horse's nutrition!"*
