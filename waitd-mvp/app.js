// WAITD MVP - Equine scheduling demo

/** Utilities **/
const byId = (id) => document.getElementById(id);
const fmt = new Intl.NumberFormat(undefined, { maximumFractionDigits: 1 });
const pad = (n) => String(n).padStart(2, '0');

function parseTimeToMinutes(hhmm) {
  const [h, m] = hhmm.split(':').map(Number);
  return h * 60 + m;
}
function minutesToTime(m) {
  const h = Math.floor(m / 60);
  const mm = m % 60;
  return `${pad(h)}:${pad(mm)}`;
}

function haversineMiles(a, b) {
  const R = 3958.8; // miles
  const toRad = (d) => (d * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLon = toRad(b.lon - a.lon);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const s = Math.sin(dLat / 2) ** 2 + Math.sin(dLon / 2) ** 2 * Math.cos(lat1) * Math.cos(lat2);
  return 2 * R * Math.asin(Math.sqrt(s));
}

/** Demo data **/
const demo = {
  providers: [
    { id: 'dr-wells', name: 'Dr. Wells', start: '07:30', end: '18:00', home: { lat: 39.75, lon: -104.99 } },
    { id: 'dr-ramirez', name: 'Dr. Ramirez', start: '08:00', end: '17:30', home: { lat: 39.71, lon: -104.98 } },
  ],
  farms: [
    { id: 'sunset', name: 'Sunset Stables', bio: 'low', lat: 39.78, lon: -105.05 },
    { id: 'pine', name: 'Pine Ridge Farm', bio: 'medium', lat: 39.66, lon: -104.85 },
    { id: 'blue', name: 'Blue Creek Ranch', bio: 'high', lat: 39.83, lon: -104.90 },
    { id: 'oak', name: 'Oak Meadow', bio: 'low', lat: 39.70, lon: -105.10 },
  ],
  types: [
    { id: 'wellness', name: 'Wellness Exam', durationMin: 40, risk: 'low' },
    { id: 'lameness', name: 'Lameness Workup', durationMin: 75, risk: 'medium' },
    { id: 'dental', name: 'Dental Float', durationMin: 60, risk: 'medium' },
    { id: 'colic', name: 'Suspected Colic', durationMin: 45, risk: 'high', emergency: true },
    { id: 'herd', name: 'Herd Vaccinations (x5)', durationMin: 75, risk: 'low', herd: true },
  ],
  scenarios: {
    baseline: [
      { owner: 'Robinson', type: 'wellness', farm: 'sunset', window: '08:00-10:00' },
      { owner: 'Nguyen', type: 'dental', farm: 'pine', window: '09:30-12:00' },
      { owner: 'Baker', type: 'lameness', farm: 'blue', window: '13:00-15:00' },
      { owner: 'Singh', type: 'wellness', farm: 'oak', window: '15:00-17:00' },
    ],
    'midday-emergency': [
      { owner: 'Robinson', type: 'wellness', farm: 'sunset', window: '08:00-10:00' },
      { owner: 'Nguyen', type: 'dental', farm: 'pine', window: '09:30-12:00' },
      { owner: 'Harris', type: 'colic', farm: 'blue', window: '11:30-12:30' },
      { owner: 'Singh', type: 'wellness', farm: 'oak', window: '15:00-17:00' },
    ],
    'herd-day': [
      { owner: 'Ranch Co-op', type: 'herd', farm: 'blue', window: '09:00-12:00' },
      { owner: 'Robinson', type: 'wellness', farm: 'sunset', window: '13:00-15:00' },
      { owner: 'Fields', type: 'dental', farm: 'oak', window: '15:00-17:00' },
    ],
  },
};

/** State **/
let bookings = [];

/** Simple equine-aware heuristic optimizer
 * Goals:
 * - Respect preferred windows when possible
 * - Minimize travel time and miles (nearest-next from current location)
 * - Order by biosecurity risk low → medium → high if enabled
 * - Group herd visits at the same barn if enabled
 * - Reserve emergency slack if enabled
 * - Include load/unload time per stop
 */
function optimizeSchedule(options) {
  const provider = demo.providers.find((p) => p.id === options.providerId);
  const dayStartMin = parseTimeToMinutes(options.startTime ?? provider.start);
  const dayEndMin = parseTimeToMinutes(options.endTime ?? provider.end);
  const speedMph = options.speedMph ?? 40;
  const loadMin = options.loadMin ?? 10;

  // clone and enrich
  const items = bookings.map((b, idx) => ({
    id: `bk-${idx + 1}`,
    ...b,
    typeMeta: demo.types.find((t) => t.id === b.type),
    farmMeta: demo.farms.find((f) => f.id === b.farm),
  }));

  // Optional grouping: herd visits grouped by farm
  if (options.groupHerd && items.some((i) => i.typeMeta.herd)) {
    // Bubble herd items of same farm to be adjacent
    items.sort((a, b) => {
      const ah = a.typeMeta.herd ? 1 : 0;
      const bh = b.typeMeta.herd ? 1 : 0;
      if (ah !== bh) return bh - ah; // herd first to lock in blocks
      if (ah === 1 && a.farm !== b.farm) return a.farm.localeCompare(b.farm);
      return 0;
    });
  }

  // Biosecurity ordering low→medium→high
  if (options.biosecurityOrder) {
    const order = { low: 0, medium: 1, high: 2 };
    items.sort((a, b) => (order[a.farmMeta.bio] ?? 0) - (order[b.farmMeta.bio] ?? 0));
  }

  // Sort by window start as primary, to respect preferences loosely
  items.sort((a, b) => {
    const aStart = parseTimeToMinutes(a.window.split('-')[0]);
    const bStart = parseTimeToMinutes(b.window.split('-')[0]);
    return aStart - bStart;
  });

  // Greedy route: nearest-next from current location among feasible-window items
  let currentLoc = provider.home;
  let currentTime = dayStartMin;
  const emergencySlack = options.emergencySlack ? 30 : 0;
  const plan = [];
  let totalMiles = 0;

  const remaining = [...items];
  while (remaining.length > 0) {
    // Filter feasible wrt window and day end
    const feasible = remaining.filter((it) => {
      const [wStartStr, wEndStr] = it.window.split('-');
      const wStart = parseTimeToMinutes(wStartStr);
      const wEnd = parseTimeToMinutes(wEndStr);
      const driveMiles = haversineMiles(currentLoc, it.farmMeta);
      const driveMin = (driveMiles / speedMph) * 60 + loadMin;
      const startCandidate = Math.max(currentTime + Math.ceil(driveMin), wStart);
      const endCandidate = startCandidate + it.typeMeta.durationMin;
      return endCandidate <= Math.min(dayEndMin - emergencySlack, wEnd + 60); // allow late within +60
    });

    if (feasible.length === 0) {
      // No feasible; push day end
      break;
    }

    // Choose nearest-next by distance from currentLoc
    feasible.sort((a, b) => {
      const da = haversineMiles(currentLoc, a.farmMeta);
      const db = haversineMiles(currentLoc, b.farmMeta);
      return da - db;
    });
    const next = feasible[0];

    // Compute timings
    const [wStartStr] = next.window.split('-');
    const wStart = parseTimeToMinutes(wStartStr);
    const driveMiles = haversineMiles(currentLoc, next.farmMeta);
    const driveMin = (driveMiles / speedMph) * 60 + loadMin;
    const startAt = Math.max(currentTime + Math.ceil(driveMin), wStart);
    const endAt = startAt + next.typeMeta.durationMin;
    const wait = Math.max(0, startAt - currentTime - Math.ceil(driveMin));

    plan.push({
      id: next.id,
      owner: next.owner,
      farm: next.farmMeta.name,
      farmId: next.farm,
      bio: next.farmMeta.bio,
      type: next.typeMeta.name,
      risk: next.typeMeta.risk,
      emergency: !!next.typeMeta.emergency,
      driveMiles: Math.round(driveMiles * 10) / 10,
      startMin: startAt,
      endMin: endAt,
      waitMin: wait,
    });

    totalMiles += driveMiles;
    currentLoc = next.farmMeta;
    currentTime = endAt;
    const idx = remaining.findIndex((r) => r.id === next.id || (r.owner === next.owner && r.farm === next.farm && r.type === next.type));
    remaining.splice(idx, 1);
  }

  // KPIs
  const totalVisitMin = plan.reduce((s, x) => s + (x.endMin - x.startMin), 0);
  const daySpan = (dayEndMin - dayStartMin) || 1;
  const utilization = Math.min(100, Math.round((totalVisitMin / (daySpan - (options.emergencySlack ? 30 : 0))) * 100));
  const avgWait = plan.length ? Math.round(plan.reduce((s, x) => s + x.waitMin, 0) / plan.length) : 0;
  const overtime = Math.max(0, currentTime - dayEndMin);

  return { plan, totalMiles: Math.round(totalMiles * 10) / 10, utilization, avgWait, overtime };
}

/** Rendering **/
function renderTimeline(plan, options) {
  const container = byId('timeline');
  container.innerHTML = '';
  const provider = demo.providers.find((p) => p.id === options.providerId);
  const start = parseTimeToMinutes(options.startTime ?? provider.start);
  const end = parseTimeToMinutes(options.endTime ?? provider.end);
  const pxPerMin = 2; // vertical scale
  container.style.height = `${(end - start) * pxPerMin}px`;

  // Time labels each hour
  const axis = document.createElement('div');
  axis.className = 'time-axis';
  for (let t = Math.ceil(start / 60) * 60; t <= end; t += 60) {
    const lab = document.createElement('div');
    lab.className = 'time-label';
    lab.style.top = `${(t - start) * pxPerMin}px`;
    lab.textContent = minutesToTime(t);
    axis.appendChild(lab);
  }
  container.appendChild(axis);

  // Slots
  for (const s of plan) {
    const el = document.createElement('div');
    el.className = `slot ${s.risk}` + (s.emergency ? ' emergency' : '');
    el.style.top = `${(s.startMin - start) * pxPerMin}px`;
    el.style.height = `${(s.endMin - s.startMin) * pxPerMin - 2}px`;
    el.innerHTML = `
      <div class="title">${s.type} • ${s.owner}</div>
      <div class="meta">${s.farm} · ${minutesToTime(s.startMin)}–${minutesToTime(s.endMin)} · ${fmt.format(s.driveMiles)} mi · ${s.bio}</div>
    `;
    container.appendChild(el);
  }
}

function renderStops(plan) {
  const list = byId('stops');
  list.innerHTML = '';
  for (const s of plan) {
    const li = document.createElement('li');
    li.innerHTML = `<strong>${s.farm}</strong> — ${s.type} for ${s.owner} <span class="dist">(${fmt.format(s.driveMiles)} mi)</span>`;
    list.appendChild(li);
  }
}

function renderKpis(metrics) {
  byId('kpi-wait').textContent = `${metrics.avgWait} min`;
  byId('kpi-util').textContent = `${metrics.utilization}%`;
  byId('kpi-miles').textContent = `${fmt.format(metrics.totalMiles)} mi`;
  byId('kpi-ot').textContent = metrics.overtime > 0 ? `${metrics.overtime} min` : '0';
}

function runAndRender() {
  const options = collectOptions();
  const { plan, totalMiles, utilization, avgWait, overtime } = optimizeSchedule(options);
  renderTimeline(plan, options);
  renderStops(plan);
  renderKpis({ totalMiles, utilization, avgWait, overtime });
}

/** UI Wiring **/
function populateSelects() {
  const providerSelect = byId('provider-select');
  providerSelect.innerHTML = demo.providers.map((p) => `<option value="${p.id}">${p.name}</option>`).join('');
  providerSelect.value = demo.providers[0].id;

  const farmSelect = byId('bk-farm');
  farmSelect.innerHTML = demo.farms.map((f) => `<option value="${f.id}">${f.name} (${f.bio})</option>`).join('');

  const typeSelect = byId('bk-type');
  typeSelect.innerHTML = demo.types.map((t) => `<option value="${t.id}">${t.name}</option>`).join('');
}

function seedScenario(name) {
  bookings = demo.scenarios[name].map((x) => ({ ...x }));
}

function collectOptions() {
  return {
    providerId: byId('provider-select').value,
    startTime: byId('start-time').value,
    endTime: byId('end-time').value,
    biosecurityOrder: byId('chk-biosecurity').checked,
    groupHerd: byId('chk-herd-grouping').checked,
    emergencySlack: byId('chk-emergency-slack').checked,
    speedMph: Number(byId('speed-mph').value),
    loadMin: Number(byId('load-min').value),
  };
}

function openModal() { byId('modal').classList.remove('hidden'); }
function closeModal() { byId('modal').classList.add('hidden'); }

function setupEvents() {
  byId('btn-run').addEventListener('click', runAndRender);
  byId('btn-print').addEventListener('click', () => window.print());
  byId('btn-reset').addEventListener('click', () => {
    const scenario = byId('scenario-select').value;
    seedScenario(scenario);
    runAndRender();
  });
  byId('scenario-select').addEventListener('change', (e) => {
    seedScenario(e.target.value);
    runAndRender();
  });
  byId('btn-add-booking').addEventListener('click', () => {
    byId('bk-owner').value = '';
    openModal();
  });
  byId('modal-close').addEventListener('click', closeModal);
  byId('bk-submit').addEventListener('click', () => {
    const owner = byId('bk-owner').value || 'Walk-in';
    const farm = byId('bk-farm').value;
    const type = byId('bk-type').value;
    const window = byId('bk-window').value;
    bookings.push({ owner, farm, type, window });
    closeModal();
    runAndRender();
  });
}

function init() {
  populateSelects();
  seedScenario('baseline');
  runAndRender();
  setupEvents();
}

document.addEventListener('DOMContentLoaded', init);

