package de.zweidenker.connectivity.list

import android.content.Context
import android.os.Build
import android.os.Handler
import android.support.annotation.RequiresApi
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import de.zweidenker.connectivity.R
import de.zweidenker.connectivity.config.DeviceConfigActivity
import de.zweidenker.p2p.core.Device
import de.zweidenker.p2p.core.IdGenerator
import kotlinx.android.synthetic.main.item_device.view.*
import kotlinx.android.synthetic.main.item_loading.view.*

/**
 * This Adapter displays a list of Device through a RecyclerView.
 * It contains also a header and footer item to wrap around the list for status and navigation bar.
 * The header also contains extra space for a header on the page which can be scrolled away with the list.
 */
class DeviceAdapter(context: Context) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private val itemIndexMap = HashMap<Long, Int>()
    private val itemList = ArrayList<Device>()
    private val headerId = IdGenerator.getId()
    private val footerId = IdGenerator.getId()
    private var headerSize = 0
    private var headerBottomMargin = context.resources.getDimensionPixelSize(R.dimen.list_header_margin)
    private var footerSize = 0
    private var foregroundHandler = Handler(context.mainLooper)

    init {
        setHasStableIds(true)
    }

    override fun getItemViewType(position: Int): Int {
        return when {
            position == 0 -> ViewTypes.Header.ordinal
            position >itemList.size -> ViewTypes.Footer.ordinal
            else -> ViewTypes.Device.ordinal
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when(viewType) {
            ViewTypes.Device.ordinal -> {
                val inflater = LayoutInflater.from(parent.context)
                val view = inflater.inflate(R.layout.item_device, parent, false)
                DeviceViewHolder(view)
            }
            ViewTypes.Header.ordinal -> {
                val view = View(parent.context)
                view.layoutParams = ViewGroup.LayoutParams(1, 1)
                SpacerViewHolder(view, view)
            }
            else -> {
                val inflater = LayoutInflater.from(parent.context)
                val view = inflater.inflate(R.layout.item_loading, parent, false)
                SpacerViewHolder(view, view.loading_spacer)
            }
        }
    }

    override fun getItemId(position: Int): Long {
        return when (position) {
            0 -> headerId
            itemList.size + 1 -> footerId
            else -> itemList[position - 1].id
        }
    }

    override fun getItemCount(): Int {
        return itemList.size + 2
    }

    override fun onBindViewHolder(viewHolder: RecyclerView.ViewHolder, position: Int) {
        when (position) {
            0 -> (viewHolder as? SpacerViewHolder)?.bind(headerSize)
            itemList.size + 1 -> (viewHolder as? SpacerViewHolder)?.bind(footerSize)
            else -> {
                val item = itemList[position - 1]
                (viewHolder as? DeviceViewHolder)?.bind(item)
            }
        }
    }

    override fun onViewRecycled(holder: RecyclerView.ViewHolder) {
        (holder as? DeviceViewHolder)?.recycle()
        super.onViewRecycled(holder)
    }

    fun addItem(device: Device) {
        synchronized(this) {
            val currentIndex = itemIndexMap[device.id]
            if (currentIndex == null) {
                val newIndex = itemList.size
                itemIndexMap[device.id] = newIndex
                itemList.add(device)
                foregroundHandler.post {
                    notifyItemInserted(newIndex + 1)
                }
                return
            }
            val currentDevice = itemList[currentIndex]
            if (device != currentDevice) {
                itemList[currentIndex] = device
                foregroundHandler.post {
                    notifyItemChanged(currentIndex + 1)
                }
            }
        }
    }

    fun clear() {
        synchronized(this) {
            itemIndexMap.clear()
            itemList.clear()
            foregroundHandler.post {
                notifyDataSetChanged()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT_WATCH)
    fun setInsets(insets: WindowInsets) {
        headerSize = insets.systemWindowInsetTop + headerBottomMargin
        footerSize = insets.systemWindowInsetBottom
        foregroundHandler.post {
            notifyItemChanged(0)
            notifyItemChanged(itemList.size + 1)
        }
    }

    private enum class ViewTypes {
        Device,
        Header,
        Footer
    }

    private class DeviceViewHolder(itemView: View): RecyclerView.ViewHolder(itemView) {
        private val titleTextView = itemView.card_title
        private val subtitleTextView = itemView.card_subtitle
        private val detailsTextView = itemView.card_detail

        fun bind(device: Device) {
            titleTextView.text = device.userIdentifier
            subtitleTextView.text = device.domainName
            detailsTextView.text = device.connectionStatus.name
            itemView.setOnClickListener {
                DeviceConfigActivity.startActivity(it.context, device)
                //TODO: Overwrite pending transition?
            }
        }

        fun recycle() {
            itemView.setOnClickListener(null)
        }
    }

    private class SpacerViewHolder(itemView: View, private val spacingView: View): RecyclerView.ViewHolder(itemView) {

        fun bind(size: Int) {
            spacingView.layoutParams = spacingView.layoutParams.apply {
                height = size
            }
        }
    }
}
