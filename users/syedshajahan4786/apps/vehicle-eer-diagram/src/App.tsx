import { useState } from 'react'
import './styles.css'

interface AttributeInfo {
  name: string
  isPK?: boolean
  inherited?: boolean
}

function EntityBox({ x, y, width, height, label, isSubtype }: {
  x: number; y: number; width: number; height: number; label: string; isSubtype?: boolean
}) {
  return (
    <g>
      <rect
        x={x - width / 2} y={y - height / 2}
        width={width} height={height}
        fill={isSubtype ? '#e8f5e9' : '#e3f2fd'}
        stroke={isSubtype ? '#2e7d32' : '#1565c0'}
        strokeWidth={2.5}
        rx={4}
      />
      <text x={x} y={y + 6} textAnchor="middle" fontSize={16} fontWeight="bold"
        fill={isSubtype ? '#1b5e20' : '#0d47a1'}>
        {label}
      </text>
    </g>
  )
}

function AttributeOval({ cx, cy, label, isPK, isHighlighted, inherited }: {
  cx: number; cy: number; label: string; isPK?: boolean; isHighlighted?: boolean; inherited?: boolean
}) {
  const rx = Math.max(label.length * 4.5 + 12, 50)
  const ry = 18
  const fill = inherited ? '#fff9c4' : isHighlighted ? '#bbdefb' : '#ffffff'
  const stroke = inherited ? '#f9a825' : isHighlighted ? '#1565c0' : '#546e7a'

  return (
    <g>
      <ellipse cx={cx} cy={cy} rx={rx} ry={ry}
        fill={fill} stroke={stroke} strokeWidth={isHighlighted ? 2.5 : 1.5}
      />
      <text x={cx} y={cy + 5} textAnchor="middle" fontSize={12}
        fill="#263238"
        textDecoration={isPK ? 'underline' : 'none'}
        fontWeight={isPK ? 'bold' : 'normal'}>
        {label}
      </text>
      {isPK && (
        <text x={cx + rx - 14} y={cy - 6} fontSize={9} fill="#c62828" fontWeight="bold">PK</text>
      )}
      {inherited && (
        <text x={cx + rx - 14} y={cy - 6} fontSize={9} fill="#f57f17" fontWeight="bold">IN</text>
      )}
    </g>
  )
}

function ConnectingLine({ x1, y1, x2, y2, dashed }: { x1: number; y1: number; x2: number; y2: number; dashed?: boolean }) {
  return (
    <line x1={x1} y1={y1} x2={x2} y2={y2}
      stroke="#78909c" strokeWidth={1.5}
      strokeDasharray={dashed ? '5,3' : undefined}
    />
  )
}

function ISARelationship({ cx, cy }: { cx: number; cy: number }) {
  return (
    <g>
      <circle cx={cx} cy={cy} r={28}
        fill="#fce4ec" stroke="#c62828" strokeWidth={2.5}
      />
      <text x={cx} y={cy + 5} textAnchor="middle" fontSize={14} fontWeight="bold" fill="#b71c1c">
        ISA
      </text>
      <text x={cx} y={cy + 48} textAnchor="middle" fontSize={14} fontWeight="bold" fill="#c62828">
        d
      </text>
      <text x={cx} y={cy - 38} textAnchor="middle" fontSize={11} fontWeight="bold" fill="#6a1b9a">
        Total
      </text>
    </g>
  )
}

export default function App() {
  const [hoveredEntity, setHoveredEntity] = useState<string | null>(null)
  const [showLegend, setShowLegend] = useState(true)
  const [showInherited, setShowInherited] = useState(true)

  const vehicleX = 550, vehicleY = 100
  const isaCX = 550, isaCY = 260
  const carX = 280, carY = 440
  const truckX = 820, truckY = 440

  const vehicleAttrs: { attr: AttributeInfo; cx: number; cy: number }[] = [
    { attr: { name: 'Vehicle_ID', isPK: true }, cx: 550, cy: 20 },
    { attr: { name: 'Registration_Number' }, cx: 340, cy: 40 },
    { attr: { name: 'Manufacturer' }, cx: 340, cy: 100 },
    { attr: { name: 'Model' }, cx: 760, cy: 40 },
    { attr: { name: 'Year' }, cx: 760, cy: 100 },
    { attr: { name: 'Purchase_Price' }, cx: 550, cy: 175 },
  ]

  const carAttrs: { attr: AttributeInfo; cx: number; cy: number }[] = [
    { attr: { name: 'Number_of_Doors' }, cx: 100, cy: 380 },
    { attr: { name: 'Fuel_Type' }, cx: 100, cy: 440 },
    { attr: { name: 'Seating_Capacity' }, cx: 100, cy: 500 },
  ]

  const carInherited: { attr: AttributeInfo; cx: number; cy: number }[] = showInherited ? [
    { attr: { name: 'Vehicle_ID', isPK: true, inherited: true }, cx: 280, cy: 530 },
    { attr: { name: 'Registration_Number', inherited: true }, cx: 430, cy: 530 },
    { attr: { name: 'Manufacturer', inherited: true }, cx: 280, cy: 575 },
    { attr: { name: 'Model', inherited: true }, cx: 430, cy: 575 },
    { attr: { name: 'Year', inherited: true }, cx: 280, cy: 620 },
    { attr: { name: 'Purchase_Price', inherited: true }, cx: 430, cy: 620 },
  ] : []

  const truckAttrs: { attr: AttributeInfo; cx: number; cy: number }[] = [
    { attr: { name: 'Load_Capacity' }, cx: 1000, cy: 380 },
    { attr: { name: 'Truck_Type' }, cx: 1000, cy: 440 },
    { attr: { name: 'Number_of_Axles' }, cx: 1000, cy: 500 },
  ]

  const truckInherited: { attr: AttributeInfo; cx: number; cy: number }[] = showInherited ? [
    { attr: { name: 'Vehicle_ID', isPK: true, inherited: true }, cx: 820, cy: 530 },
    { attr: { name: 'Registration_Number', inherited: true }, cx: 670, cy: 530 },
    { attr: { name: 'Manufacturer', inherited: true }, cx: 820, cy: 575 },
    { attr: { name: 'Model', inherited: true }, cx: 670, cy: 575 },
    { attr: { name: 'Year', inherited: true }, cx: 820, cy: 620 },
    { attr: { name: 'Purchase_Price', inherited: true }, cx: 670, cy: 620 },
  ] : []

  const svgWidth = 1100
  const svgHeight = showInherited ? 680 : 520

  return (
    <div className="app-container">
      <header className="header">
        <h1>🚗 EER Diagram: Vehicle Specialization</h1>
        <p className="subtitle">Supertype/Subtype Relationship — Disjoint &amp; Total Specialization</p>
        <div className="controls">
          <button onClick={() => setShowInherited(!showInherited)} className="toggle-btn">
            {showInherited ? '🔽 Hide' : '▶ Show'} Inherited Attributes
          </button>
          <button onClick={() => setShowLegend(!showLegend)} className="toggle-btn">
            {showLegend ? '🔽 Hide' : '▶ Show'} Legend
          </button>
        </div>
      </header>

      <div className="diagram-wrapper">
        <svg width={svgWidth} height={svgHeight} viewBox={`0 0 ${svgWidth} ${svgHeight}`}>
          <rect width={svgWidth} height={svgHeight} fill="#fafafa" rx={8} />

          {/* VEHICLE SUPERTYPE ATTRIBUTES */}
          {vehicleAttrs.map(({ attr, cx, cy }) => (
            <g key={`va-${attr.name}`}>
              <ConnectingLine x1={vehicleX} y1={vehicleY} x2={cx} y2={cy} />
              <AttributeOval
                cx={cx} cy={cy} label={attr.name}
                isPK={attr.isPK}
                isHighlighted={hoveredEntity === 'vehicle'}
              />
            </g>
          ))}

          {/* VEHICLE SUPERTYPE ENTITY */}
          <g onMouseEnter={() => setHoveredEntity('vehicle')}
             onMouseLeave={() => setHoveredEntity(null)}>
            <EntityBox x={vehicleX} y={vehicleY} width={160} height={50} label="VEHICLE" />
          </g>

          {/* ISA RELATIONSHIP - double line from Vehicle = total */}
          <line x1={vehicleX} y1={vehicleY + 25} x2={isaCX} y2={isaCY - 28}
            stroke="#c62828" strokeWidth={3} />
          <line x1={vehicleX - 4} y1={vehicleY + 25} x2={isaCX - 4} y2={isaCY - 28}
            stroke="#c62828" strokeWidth={1.5} />
          <line x1={vehicleX + 4} y1={vehicleY + 25} x2={isaCX + 4} y2={isaCY - 28}
            stroke="#c62828" strokeWidth={1.5} />

          <ISARelationship cx={isaCX} cy={isaCY} />

          {/* LINES FROM ISA TO SUBTYPES - double line = total */}
          <line x1={isaCX - 20} y1={isaCY + 28} x2={carX + 15} y2={carY - 25}
            stroke="#c62828" strokeWidth={3} />
          <line x1={isaCX - 24} y1={isaCY + 28} x2={carX + 11} y2={carY - 25}
            stroke="#c62828" strokeWidth={1.5} />
          <line x1={isaCX - 16} y1={isaCY + 28} x2={carX + 19} y2={carY - 25}
            stroke="#c62828" strokeWidth={1.5} />

          <line x1={isaCX + 20} y1={isaCY + 28} x2={truckX - 15} y2={truckY - 25}
            stroke="#c62828" strokeWidth={3} />
          <line x1={isaCX + 24} y1={isaCY + 28} x2={truckX - 19} y2={truckY - 25}
            stroke="#c62828" strokeWidth={1.5} />
          <line x1={isaCX + 16} y1={isaCY + 28} x2={truckX - 11} y2={truckY - 25}
            stroke="#c62828" strokeWidth={1.5} />

          {/* CAR SUBTYPE */}
          {carAttrs.map(({ attr, cx, cy }) => (
            <g key={`ca-${attr.name}`}>
              <ConnectingLine x1={carX} y1={carY} x2={cx} y2={cy} />
              <AttributeOval cx={cx} cy={cy} label={attr.name}
                isHighlighted={hoveredEntity === 'car'} />
            </g>
          ))}

          {carInherited.map(({ attr, cx, cy }) => (
            <g key={`ci-${attr.name}`}>
              <ConnectingLine x1={carX} y1={carY + 25} x2={cx} y2={cy - 18} dashed />
              <AttributeOval cx={cx} cy={cy} label={attr.name}
                isPK={attr.isPK} inherited
                isHighlighted={hoveredEntity === 'car'} />
            </g>
          ))}

          <g onMouseEnter={() => setHoveredEntity('car')}
             onMouseLeave={() => setHoveredEntity(null)}>
            <EntityBox x={carX} y={carY} width={140} height={50} label="CAR" isSubtype />
          </g>

          {/* TRUCK SUBTYPE */}
          {truckAttrs.map(({ attr, cx, cy }) => (
            <g key={`ta-${attr.name}`}>
              <ConnectingLine x1={truckX} y1={truckY} x2={cx} y2={cy} />
              <AttributeOval cx={cx} cy={cy} label={attr.name}
                isHighlighted={hoveredEntity === 'truck'} />
            </g>
          ))}

          {truckInherited.map(({ attr, cx, cy }) => (
            <g key={`ti-${attr.name}`}>
              <ConnectingLine x1={truckX} y1={truckY + 25} x2={cx} y2={cy - 18} dashed />
              <AttributeOval cx={cx} cy={cy} label={attr.name}
                isPK={attr.isPK} inherited
                isHighlighted={hoveredEntity === 'truck'} />
            </g>
          ))}

          <g onMouseEnter={() => setHoveredEntity('truck')}
             onMouseLeave={() => setHoveredEntity(null)}>
            <EntityBox x={truckX} y={truckY} width={140} height={50} label="TRUCK" isSubtype />
          </g>

          {/* CONSTRAINT LABELS */}
          <g>
            <rect x={440} y={290} width={220} height={50} rx={6}
              fill="#fff3e0" stroke="#e65100" strokeWidth={1.5} />
            <text x={550} y={308} textAnchor="middle" fontSize={12} fontWeight="bold" fill="#e65100">
              Constraints:
            </text>
            <text x={550} y={328} textAnchor="middle" fontSize={11} fill="#bf360c">
              d = Disjoint | Total Completeness
            </text>
          </g>
        </svg>
      </div>

      {/* LEGEND */}
      {showLegend && (
        <div className="legend">
          <h3>📖 EER Notation Legend</h3>
          <div className="legend-grid">
            <div className="legend-item">
              <svg width="60" height="35">
                <rect x="5" y="5" width="50" height="25" fill="#e3f2fd" stroke="#1565c0" strokeWidth="2" rx="3" />
              </svg>
              <span><strong>Rectangle</strong> — Supertype Entity (Vehicle)</span>
            </div>
            <div className="legend-item">
              <svg width="60" height="35">
                <rect x="5" y="5" width="50" height="25" fill="#e8f5e9" stroke="#2e7d32" strokeWidth="2" rx="3" />
              </svg>
              <span><strong>Green Rectangle</strong> — Subtype Entity (Car, Truck)</span>
            </div>
            <div className="legend-item">
              <svg width="60" height="35">
                <ellipse cx="30" cy="17" rx="25" ry="13" fill="#fff" stroke="#546e7a" strokeWidth="1.5" />
              </svg>
              <span><strong>Oval</strong> — Attribute</span>
            </div>
            <div className="legend-item">
              <svg width="60" height="35">
                <ellipse cx="30" cy="17" rx="25" ry="13" fill="#fff9c4" stroke="#f9a825" strokeWidth="1.5" />
                <text x="46" y="10" fontSize="8" fill="#f57f17" fontWeight="bold">IN</text>
              </svg>
              <span><strong>Yellow Oval (IN)</strong> — Inherited Attribute</span>
            </div>
            <div className="legend-item">
              <svg width="60" height="35">
                <circle cx="30" cy="17" r="14" fill="#fce4ec" stroke="#c62828" strokeWidth="2" />
                <text x="30" y="21" textAnchor="middle" fontSize="9" fontWeight="bold" fill="#b71c1c">ISA</text>
              </svg>
              <span><strong>Circle with ISA</strong> — Specialization Relationship</span>
            </div>
            <div className="legend-item">
              <svg width="60" height="35">
                <text x="30" y="22" textAnchor="middle" fontSize="16" fontWeight="bold" fill="#c62828">d</text>
              </svg>
              <span><strong>"d"</strong> — Disjoint constraint (mutually exclusive subtypes)</span>
            </div>
            <div className="legend-item">
              <svg width="60" height="35">
                <line x1="10" y1="14" x2="50" y2="14" stroke="#c62828" strokeWidth="3" />
                <line x1="10" y1="20" x2="50" y2="20" stroke="#c62828" strokeWidth="1.5" />
              </svg>
              <span><strong>Double Line</strong> — Total completeness (every vehicle must be Car or Truck)</span>
            </div>
            <div className="legend-item">
              <svg width="60" height="35">
                <text x="30" y="22" textAnchor="middle" fontSize="11" fill="#263238" textDecoration="underline" fontWeight="bold">ID</text>
                <text x="42" y="10" fontSize="8" fill="#c62828" fontWeight="bold">PK</text>
              </svg>
              <span><strong>Underlined + PK</strong> — Primary Key</span>
            </div>
            <div className="legend-item">
              <svg width="60" height="35">
                <line x1="10" y1="17" x2="50" y2="17" stroke="#78909c" strokeWidth="1.5" strokeDasharray="5,3" />
              </svg>
              <span><strong>Dashed Line</strong> — Inherited attribute connection</span>
            </div>
          </div>
        </div>
      )}

      {/* TASK ANSWERS */}
      <div className="answers">
        <h2>📋 Task Solutions</h2>

        <div className="task-card">
          <h3>1. Supertype &amp; Subtypes</h3>
          <ul>
            <li><strong>Supertype:</strong> Vehicle — the general entity containing common attributes</li>
            <li><strong>Subtypes:</strong> Car and Truck — specialized entities with unique attributes</li>
          </ul>
        </div>

        <div className="task-card">
          <h3>2. Common Attributes of Vehicle</h3>
          <div className="attr-list">
            <span className="attr-tag">Vehicle_ID (PK)</span>
            <span className="attr-tag">Registration_Number</span>
            <span className="attr-tag">Manufacturer</span>
            <span className="attr-tag">Model</span>
            <span className="attr-tag">Year</span>
            <span className="attr-tag">Purchase_Price</span>
          </div>
        </div>

        <div className="task-card">
          <h3>3. Specialized Attributes</h3>
          <div className="specialized-grid">
            <div className="specialized-col car-col">
              <h4>🚗 Car</h4>
              <span className="attr-tag car-tag">Number_of_Doors</span>
              <span className="attr-tag car-tag">Fuel_Type</span>
              <span className="attr-tag car-tag">Seating_Capacity</span>
            </div>
            <div className="specialized-col truck-col">
              <h4>🚛 Truck</h4>
              <span className="attr-tag truck-tag">Load_Capacity</span>
              <span className="attr-tag truck-tag">Truck_Type</span>
              <span className="attr-tag truck-tag">Number_of_Axles</span>
            </div>
          </div>
        </div>

        <div className="task-card">
          <h3>4. Primary Key &amp; Inheritance</h3>
          <p>
            <strong>Vehicle_ID</strong> is the primary key of the <em>Vehicle</em> supertype.
            It is <strong>inherited</strong> by both <em>Car</em> and <em>Truck</em> subtypes.
            Each Car and Truck instance has a unique Vehicle_ID that identifies it across the entire hierarchy.
            The PK is underlined in the diagram and marked with "PK" badge.
          </p>
        </div>

        <div className="task-card">
          <h3>5. ISA Specialization Relationship</h3>
          <p>
            The <strong>ISA</strong> (is-a) relationship is represented by a <span style={{ color: '#c62828', fontWeight: 'bold' }}>circle labeled "ISA"</span> connected
            to the Vehicle supertype above and the Car and Truck subtypes below.
            This means: <em>"A Car <strong>IS A</strong> Vehicle"</em> and <em>"A Truck <strong>IS A</strong> Vehicle"</em>.
          </p>
        </div>

        <div className="task-card">
          <h3>6. Disjoint vs. Overlapping</h3>
          <p>
            The specialization is <strong style={{ color: '#c62828' }}>DISJOINT (d)</strong> — a vehicle can be classified as
            <strong> either a Car OR a Truck, but NOT both</strong>.
            The "d" constraint is shown below the ISA circle in the diagram.
          </p>
        </div>

        <div className="task-card">
          <h3>7. Total vs. Partial</h3>
          <p>
            The specialization is <strong style={{ color: '#6a1b9a' }}>TOTAL (complete)</strong> — <em>every</em> vehicle
            in the system <strong>must</strong> be classified as either a Car or a Truck.
            No vehicle can exist without belonging to one of the two subtypes.
            This is represented by <strong>double lines</strong> connecting the Vehicle entity to the ISA circle.
          </p>
        </div>

        <div className="task-card">
          <h3>8. Complete EER Diagram Summary</h3>
          <div className="summary-table">
            <table>
              <thead>
                <tr>
                  <th>Element</th>
                  <th>Notation Used</th>
                  <th>Description</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Vehicle (Supertype)</td>
                  <td>Blue Rectangle</td>
                  <td>General entity with 6 common attributes</td>
                </tr>
                <tr>
                  <td>Car (Subtype)</td>
                  <td>Green Rectangle</td>
                  <td>Specialized entity with 3 unique attributes + 6 inherited</td>
                </tr>
                <tr>
                  <td>Truck (Subtype)</td>
                  <td>Green Rectangle</td>
                  <td>Specialized entity with 3 unique attributes + 6 inherited</td>
                </tr>
                <tr>
                  <td>ISA Relationship</td>
                  <td>Circle labeled "ISA"</td>
                  <td>Connects supertype to subtypes</td>
                </tr>
                <tr>
                  <td>Disjoint (d)</td>
                  <td>"d" below ISA circle</td>
                  <td>Vehicle is either Car or Truck, not both</td>
                </tr>
                <tr>
                  <td>Total Completeness</td>
                  <td>Double lines</td>
                  <td>Every vehicle must belong to a subtype</td>
                </tr>
                <tr>
                  <td>Primary Key</td>
                  <td>Underlined + PK badge</td>
                  <td>Vehicle_ID inherited by both subtypes</td>
                </tr>
                <tr>
                  <td>Inherited Attributes</td>
                  <td>Yellow ovals + dashed lines</td>
                  <td>Common attributes passed to subtypes</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <footer>
        <p>Vehicle EER Diagram — Specialization/Generalization (Disjoint, Total)</p>
      </footer>
    </div>
  )
}
