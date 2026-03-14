import Foundation

@MainActor
class KnowledgeViewModel: ObservableObject {
    @Published var tutorials: [Tutorial] = []
    @Published var searchText = ""
    @Published var selectedCategory: TutorialCategory?
    
    init() {
        loadTutorials()
    }
    
    private func loadTutorials() {
        tutorials = [
            Tutorial(
                title: "Basic Bike Inspection",
                description: "Learn how to perform a pre-ride safety check on your bicycle.",
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 10,
                icon: "checklist",
                steps: [
                    TutorialStep(
                        title: "Check Brakes",
                        instruction: "Squeeze each brake lever to ensure they engage properly and stop the wheel.",
                        tip: "Brakes should engage before the lever reaches the handlebar",
                        warning: "Do not ride if brakes are not functioning properly"
                    ),
                    TutorialStep(
                        title: "Check Tire Pressure",
                        instruction: "Use a pressure gauge to verify tires are inflated to the recommended PSI.",
                        tip: "Check the sidewall of your tire for recommended pressure range",
                        warning: "Underinflated tires can cause pinch flats"
                    ),
                    TutorialStep(
                        title: "Check Quick Releases",
                        instruction: "Ensure all quick releases and thru-axles are properly tightened.",
                        tip: "Quick release levers should leave an impression in your palm when closed",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Check Chain",
                        instruction: "Verify the chain is properly lubricated and not excessively worn.",
                        tip: "A dry chain will squeak and wear faster",
                        warning: nil
                    )
                ]
            ),
            Tutorial(
                title: "How to Clean Your Chain",
                description: "Learn the proper technique for cleaning and lubricating your bike chain for optimal performance.",
                category: .drivetrain,
                difficulty: .beginner,
                estimatedMinutes: 15,
                icon: "link",
                steps: [
                    TutorialStep(
                        title: "Prepare the Bike",
                        instruction: "Place your bike in a work stand or flip it upside down. Place a mat underneath to catch drips.",
                        tip: "Work in a well-ventilated area",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Apply Degreaser",
                        instruction: "Apply chain degreaser while backpedaling the cranks. Use a chain cleaning tool for best results.",
                        tip: "Let the degreaser sit for 3-5 minutes",
                        warning: "Avoid getting degreaser on brake surfaces"
                    ),
                    TutorialStep(
                        title: "Scrub and Rinse",
                        instruction: "Use a brush to scrub the chain, then rinse with water.",
                        tip: "A toothbrush works well for tight spaces",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Dry the Chain",
                        instruction: "Wipe the chain with a clean rag and let it dry completely.",
                        tip: "Allow 10-15 minutes for thorough drying",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Apply Lubricant",
                        instruction: "Apply one drop of lubricant to each link while backpedaling.",
                        tip: "Wipe off excess lube after 5 minutes",
                        warning: "Too much lube attracts dirt"
                    )
                ]
            ),
            Tutorial(
                title: "Replace Brake Pads",
                description: "Step-by-step guide to replacing worn brake pads on rim or disc brakes.",
                category: .brakes,
                difficulty: .intermediate,
                estimatedMinutes: 20,
                icon: "hand.brake",
                steps: [
                    TutorialStep(
                        title: "Remove Wheel",
                        instruction: "Remove the wheel to access brake pads more easily.",
                        tip: "For disc brakes, be careful not to squeeze the brake lever with the wheel removed",
                        warning: "Support the bike properly"
                    ),
                    TutorialStep(
                        title: "Remove Old Pads",
                        instruction: "Unscrew the retaining pin or bolt and slide out the old pads.",
                        tip: "Note the orientation of the pads for reassembly",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Clean the Caliper",
                        instruction: "Clean the caliper body and pistons with isopropyl alcohol.",
                        tip: "Push pistons back into the caliper with a tire lever",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Install New Pads",
                        instruction: "Insert new pads in the correct orientation and secure with the retaining pin.",
                        tip: "Bed in new pads with 20-30 moderate stops",
                        warning: "Do not touch the braking surface with bare fingers"
                    )
                ]
            ),
            Tutorial(
                title: "Fix a Flat Tire",
                description: "Essential skill every cyclist should know - how to fix a flat tire on the road.",
                category: .wheels,
                difficulty: .beginner,
                estimatedMinutes: 15,
                icon: "circle",
                steps: [
                    TutorialStep(
                        title: "Remove Wheel",
                        instruction: "Release brakes if necessary and remove the wheel from the bike.",
                        tip: "Shift to the smallest cog first for easier rear wheel removal",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Remove Tire",
                        instruction: "Deflate the tube completely. Use tire levers to unseat one side of the tire.",
                        tip: "Work opposite the valve stem",
                        warning: "Don't pinch the tube with levers"
                    ),
                    TutorialStep(
                        title: "Find the Puncture",
                        instruction: "Inflate the tube and listen/feel for escaping air. Check the tire for debris.",
                        tip: "Run your fingers inside the tire to find sharp objects",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Install New Tube",
                        instruction: "Slightly inflate the new tube and insert it into the tire. Seat the tire bead.",
                        tip: "Check that the tube isn't pinched between tire and rim",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Inflate and Install",
                        instruction: "Inflate to recommended pressure and reinstall the wheel.",
                        tip: "Spin the wheel to check for wobbles",
                        warning: nil
                    )
                ]
            ),
            Tutorial(
                title: "Adjust Your Derailleurs",
                description: "Learn how to index your gears and adjust derailleur limits for smooth shifting.",
                category: .drivetrain,
                difficulty: .intermediate,
                estimatedMinutes: 25,
                icon: "gearshape.2",
                steps: [
                    TutorialStep(
                        title: "Check Cable Tension",
                        instruction: "Shift to the smallest cog. Ensure the cable is properly seated and tensioned.",
                        tip: "Start with the barrel adjuster halfway out",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Set High Limit",
                        instruction: "Adjust the H-limit screw so the upper pulley aligns with the smallest cog.",
                        tip: "The chain should not rub on the next cog",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Index the Gears",
                        instruction: "Shift up one gear at a time, adjusting the barrel adjuster for smooth shifts.",
                        tip: "Quarter turns of the barrel adjuster make a big difference",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Set Low Limit",
                        instruction: "Shift to the largest cog and adjust the L-limit screw.",
                        tip: "The chain should not overshoot into the spokes",
                        warning: "Incorrect limit can cause serious damage"
                    ),
                    TutorialStep(
                        title: "Adjust B-Screw",
                        instruction: "Set the B-screw for proper pulley-to-cassette clearance.",
                        tip: "About 5-6mm gap is ideal",
                        warning: nil
                    )
                ]
            ),
            Tutorial(
                title: "Basic Bike Fit",
                description: "Adjust your bike for optimal comfort and efficiency.",
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 20,
                icon: "person",
                steps: [
                    TutorialStep(
                        title: "Set Saddle Height",
                        instruction: "Adjust saddle so your leg is slightly bent at the bottom of the pedal stroke.",
                        tip: "With heel on pedal, your leg should be fully extended",
                        warning: "Too high can cause hip rocking"
                    ),
                    TutorialStep(
                        title: "Set Saddle Fore/Aft",
                        instruction: "Position saddle so your knee is over the pedal spindle when cranks are horizontal.",
                        tip: "Use a plumb line for accuracy",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Adjust Handlebar Reach",
                        instruction: "You should have a slight bend in your elbows when riding.",
                        tip: "Stem length can be changed if needed",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Check Handlebar Height",
                        instruction: "Handlebars should be at or below saddle height for most riders.",
                        tip: "Higher bars are more comfortable for casual riding",
                        warning: nil
                    )
                ]
            ),
            Tutorial(
                title: "Suspension Setup",
                description: "Configure your suspension for your weight and riding style.",
                category: .suspension,
                difficulty: .intermediate,
                estimatedMinutes: 30,
                icon: "waveform.path",
                steps: [
                    TutorialStep(
                        title: "Set Sag",
                        instruction: "Adjust air pressure to achieve 25-30% sag for trail bikes, 15-20% for XC.",
                        tip: "Use a shock pump with a pressure gauge",
                        warning: "Never exceed maximum pressure rating"
                    ),
                    TutorialStep(
                        title: "Set Rebound",
                        instruction: "Adjust rebound so the suspension returns quickly but doesn't top out harshly.",
                        tip: "Start in the middle of the adjustment range",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Set Compression",
                        instruction: "Adjust low-speed compression for pedaling efficiency.",
                        tip: "More compression = less bob when pedaling",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Test Ride",
                        instruction: "Take a test ride and make small adjustments as needed.",
                        tip: "Keep notes on your settings",
                        warning: nil
                    )
                ]
            ),
            Tutorial(
                title: "True a Wheel",
                description: "Learn to straighten a wobbly wheel with basic tools.",
                category: .wheels,
                difficulty: .advanced,
                estimatedMinutes: 45,
                icon: "circle.circle",
                steps: [
                    TutorialStep(
                        title: "Identify the Wobble",
                        instruction: "Spin the wheel and locate where it deviates from center.",
                        tip: "Use zip ties on the frame as indicators",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Check Spoke Tension",
                        instruction: "Pluck spokes to identify loose or overly tight spokes.",
                        tip: "All spokes should have similar tone",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Adjust Spokes",
                        instruction: "Tighten spokes on the side opposite the wobble, loosen on the wobble side.",
                        tip: "Quarter turns only - small adjustments make big changes",
                        warning: "Over-tightening can damage the rim"
                    ),
                    TutorialStep(
                        title: "Check for Round",
                        instruction: "Check for hops (up/down movement) and adjust as needed.",
                        tip: "Work on one issue at a time",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Stress Relieve",
                        instruction: "Squeeze parallel spokes together to seat them properly.",
                        tip: "This helps the wheel hold its true",
                        warning: nil
                    )
                ]
            ),
            Tutorial(
                title: "Replace a Chain",
                description: "When and how to replace your worn chain.",
                category: .drivetrain,
                difficulty: .intermediate,
                estimatedMinutes: 20,
                icon: "link",
                steps: [
                    TutorialStep(
                        title: "Measure Chain Wear",
                        instruction: "Use a chain checker tool to measure chain stretch.",
                        tip: "Replace at 0.5% for 11+ speed, 0.75% for 10 speed and below",
                        warning: "A worn chain will damage your cassette and chainring"
                    ),
                    TutorialStep(
                        title: "Remove Old Chain",
                        instruction: "Use a chain tool to push out a pin, or open the quick link.",
                        tip: "Note the routing through the derailleur",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Size New Chain",
                        instruction: "Thread the new chain through the derailleur and size it correctly.",
                        tip: "Large ring to largest cog, add 2 links",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Install Chain",
                        instruction: "Connect the chain using the included pin or quick link.",
                        tip: "Quick links are reusable on some models",
                        warning: "Ensure the quick link is fully engaged"
                    ),
                    TutorialStep(
                        title: "Check Shifting",
                        instruction: "Shift through all gears to ensure smooth operation.",
                        tip: "If shifting is poor, check derailleur adjustment",
                        warning: nil
                    )
                ]
            ),
            Tutorial(
                title: "Install Tubeless Tires",
                description: "Convert your wheels to tubeless for better traction and fewer flats.",
                category: .wheels,
                difficulty: .intermediate,
                estimatedMinutes: 30,
                icon: "circle.fill",
                steps: [
                    TutorialStep(
                        title: "Prepare the Rim",
                        instruction: "Clean the rim bed and apply tubeless rim tape.",
                        tip: "Overlap the valve hole by 2 inches on each side",
                        warning: "Use the correct width tape for your rim"
                    ),
                    TutorialStep(
                        title: "Install Valve",
                        instruction: "Insert the tubeless valve through the rim tape and secure with the nut.",
                        tip: "Don't overtighten the valve nut",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Mount Tire",
                        instruction: "Install the tubeless-ready tire, ensuring the bead is seated.",
                        tip: "Some tires have directional arrows - check before installing",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Add Sealant",
                        instruction: "Add the recommended amount of sealant through the valve or by pouring it in before fully seating the tire.",
                        tip: "60-90ml is typical for mountain bike tires",
                        warning: "Shake the sealant bottle before use"
                    ),
                    TutorialStep(
                        title: "Inflate and Seat",
                        instruction: "Use a high-volume pump or compressor to seat the tire beads.",
                        tip: "You'll hear loud pops when the beads seat",
                        warning: "Never exceed the maximum tire pressure"
                    )
                ]
            ),
            Tutorial(
                title: "Bleed Hydraulic Brakes",
                description: "Remove air from your hydraulic brake system for consistent braking.",
                category: .brakes,
                difficulty: .advanced,
                estimatedMinutes: 40,
                icon: "drop.fill",
                steps: [
                    TutorialStep(
                        title: "Prepare Tools",
                        instruction: "Gather the bleed kit, mineral oil or DOT fluid (as specified), and clean rags.",
                        tip: "Use only the fluid specified by your brake manufacturer",
                        warning: "DOT fluid is corrosive - avoid contact with paint"
                    ),
                    TutorialStep(
                        title: "Position the Bike",
                        instruction: "Secure the bike so the brake caliper and lever are level.",
                        tip: "A work stand makes this easier",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Attach Bleed Kit",
                        instruction: "Remove the bleed screw and attach the syringe filled with fluid.",
                        tip: "Push fluid through slowly to avoid introducing air",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Bleed the System",
                        instruction: "Push fluid through until no air bubbles appear in the output syringe.",
                        tip: "Tap the caliper and line to dislodge air bubbles",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Finish Up",
                        instruction: "Remove syringes, reinstall bleed screws, and clean up any spilled fluid.",
                        tip: "Test brakes before riding",
                        warning: "Never ride with air in the brake lines"
                    )
                ]
            ),
            Tutorial(
                title: "Replace Cassette and Chainring",
                description: "Install a new cassette and chainring when worn.",
                category: .drivetrain,
                difficulty: .intermediate,
                estimatedMinutes: 25,
                icon: "gearshape.2.fill",
                steps: [
                    TutorialStep(
                        title: "Remove Wheel and Cassette",
                        instruction: "Remove the rear wheel. Use a chain whip and cassette tool to remove the lockring.",
                        tip: "Hold the cassette tool straight while turning",
                        warning: "The lockring is reverse-threaded"
                    ),
                    TutorialStep(
                        title: "Clean Freehub",
                        instruction: "Clean the freehub body and inspect for damage or grooves.",
                        tip: "Lightly grease the freehub splines",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Install New Cassette",
                        instruction: "Slide on the new cassette, aligning the splines correctly.",
                        tip: "The largest splines are your guide",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Torque Lockring",
                        instruction: "Install and torque the lockring to specification (usually 40 Nm).",
                        tip: "Use a torque wrench for accuracy",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Replace Chainring",
                        instruction: "Remove crank bolts and replace the chainring, torquing to spec.",
                        tip: "Note any offset or direction markings",
                        warning: nil
                    )
                ]
            ),
            Tutorial(
                title: "Service Headset Bearings",
                description: "Clean and regrease headset bearings for smooth steering.",
                category: .basics,
                difficulty: .intermediate,
                estimatedMinutes: 30,
                icon: "arrow.up.and.down",
                steps: [
                    TutorialStep(
                        title: "Remove Stem",
                        instruction: "Loosen stem bolts and top cap, then remove the stem.",
                        tip: "Hold the fork to prevent it from falling out",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Remove Bearings",
                        instruction: "Lower the fork and remove the headset bearings.",
                        tip: "Note the orientation of each bearing",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Clean and Inspect",
                        instruction: "Clean bearings and races with degreaser. Check for wear or corrosion.",
                        tip: "Replace bearings if they feel rough or notchy",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Regrease and Reassemble",
                        instruction: "Apply fresh grease to bearings and races. Reassemble in reverse order.",
                        tip: "Don't overtighten the top cap",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Adjust Preload",
                        instruction: "Tighten the top cap until there's no play but steering is smooth.",
                        tip: "Tighten stem bolts after setting preload",
                        warning: nil
                    )
                ]
            ),
            Tutorial(
                title: "Winter Bike Storage",
                description: "Properly prepare your bike for winter storage or riding.",
                category: .basics,
                difficulty: .beginner,
                estimatedMinutes: 30,
                icon: "snowflake",
                steps: [
                    TutorialStep(
                        title: "Deep Clean",
                        instruction: "Thoroughly clean the entire bike, including drivetrain.",
                        tip: "A clean bike is easier to inspect for damage",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Inspect Components",
                        instruction: "Check for wear, damage, or loose parts.",
                        tip: "Make a list of parts that need replacement",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Lubricate",
                        instruction: "Apply fresh lubricant to chain, cables, and pivot points.",
                        tip: "Use a heavier lube for winter riding",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Protect",
                        instruction: "Apply frame protector or wax to paint. Consider fenders for winter riding.",
                        tip: "Wipe down steel frames with a light oil film",
                        warning: nil
                    ),
                    TutorialStep(
                        title: "Store Properly",
                        instruction: "Store in a dry place. If hanging, avoid hanging by wheels for long periods.",
                        tip: "Let some air out of tires if storing for months",
                        warning: nil
                    )
                ]
            )
        ]
    }
    
    func filterTutorials() -> [Tutorial] {
        var filtered = tutorials
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        return filtered
    }
    
    func getTutorials(for category: TutorialCategory) -> [Tutorial] {
        tutorials.filter { $0.category == category }
    }
    
    func searchTutorials(query: String) -> [Tutorial] {
        tutorials.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.description.localizedCaseInsensitiveContains(query)
        }
    }
}
